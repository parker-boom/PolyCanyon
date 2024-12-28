import CoreLocation
import FirebaseFirestore
import Combine

class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    private var firestoreRef: Firestore!
    private var cancellables = Set<AnyCancellable>()
    
    // Dependencies
    private weak var appState: AppState?
    private weak var dataStore: DataStore?
    
    // Core location states
    @Published private(set) var locationStatus: CLAuthorizationStatus?
    @Published private(set) var lastLocation: CLLocation?
    @Published private(set) var recommendedMode: Bool = false
    @Published private(set) var trackingState: TrackingState = .inactive
    
    // Boundary definitions
    private let centerPoint = CLLocationCoordinate2D(
        latitude: 35.31461,
        longitude: -120.65238
    )
    
    private let safeZoneCorners = (
        bottomLeft: CLLocationCoordinate2D(latitude: 35.31214, longitude: -120.65529),
        topRight: CLLocationCoordinate2D(latitude: 35.31813, longitude: -120.65110)
    )
    
    private let recommendationRadius: CLLocationDistance = 48280  // 30 miles
    private let backgroundRadius: CLLocationDistance = 1609.34   // 1 mile
    
    // MARK: - Initialization
    private override init() {
        super.init()
        setupLocationManager()
        setupFirestore()
    }
    
    func configure(appState: AppState, dataStore: DataStore) {
        self.appState = appState
        self.dataStore = dataStore
        
        // Observe adventure mode changes
        appState.$adventureModeEnabled
            .sink { [weak self] isEnabled in
                self?.handleModeChange(isEnabled)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    private func setupFirestore() {
        firestoreRef = Firestore.firestore()
    }
    
    // MARK: - Public Permission Interface
    func requestInitialPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            self.permissionContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    /// Switch to specified mode and handle permission upgrades
    func setMode(_ mode: LocationMode) {
        locationMode = mode
        
        switch mode {
        case .adventure:
            locationManager.requestAlwaysAuthorization()
            startLocationUpdates()
        case .virtualTour:
            stopLocationUpdates()
        case .initial:
            break
        }
        
        // Persist mode selection
        UserDefaults.standard.set(mode == .adventure, forKey: "adventureMode")
    }
    
    // MARK: - Location Updates Control
    private func startLocationUpdates() {
        locationManager.startUpdatingLocation()
        updateTrackingState()
    }
    
    private func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        trackingState = .inactive
    }
    
    private func updateTrackingState() {
        guard appState?.adventureModeEnabled == true,
              let location = lastLocation else {
            trackingState = .inactive
            return
        }
        
        if isWithinBackgroundRange(location) {
            enableBackgroundTracking()
        } else {
            disableBackgroundTracking()
        }
    }
    
    func handleModeChange(_ isEnabled: Bool) {
        if isEnabled {
            locationManager.requestAlwaysAuthorization()
            startLocationUpdates()
        } else {
            stopLocationUpdates()
        }
    }
    
    // For onboarding recommendation only
    func getRecommendedMode(_ location: CLLocation) -> Bool {
        return isWithinRecommendationRange(location)
    }
}

// MARK: - Location Checks
extension LocationService {
    func isWithinRecommendationRange(_ location: CLLocation) -> Bool {
        let centerLocation = CLLocation(
            latitude: centerPoint.latitude,
            longitude: centerPoint.longitude
        )
        return location.distance(from: centerLocation) <= recommendationRadius
    }
    
    func isWithinBackgroundRange(_ location: CLLocation) -> Bool {
        let centerLocation = CLLocation(
            latitude: centerPoint.latitude,
            longitude: centerPoint.longitude
        )
        return location.distance(from: centerLocation) <= backgroundRadius
    }
    
    func isWithinSafeZone(coordinate: CLLocationCoordinate2D) -> Bool {
        let isWithinLatitude = coordinate.latitude >= safeZoneCorners.bottomLeft.latitude &&
                              coordinate.latitude <= safeZoneCorners.topRight.latitude
        
        let isWithinLongitude = coordinate.longitude >= safeZoneCorners.bottomLeft.longitude &&
                               coordinate.longitude <= safeZoneCorners.topRight.longitude
        
        return isWithinLatitude && isWithinLongitude
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            permissionContinuation?.resume(returning: true)
            permissionContinuation = nil
            
            if appState?.adventureModeEnabled == true {
                startLocationUpdates()
            }
            
        case .denied, .restricted:
            permissionContinuation?.resume(returning: false)
            permissionContinuation = nil
            stopLocationUpdates()
            
        case .notDetermined:
            break
            
        @unknown default:
            permissionContinuation?.resume(returning: false)
            permissionContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        
        recommendedMode = isWithinRecommendationRange(location)
        
        guard appState?.adventureModeEnabled == true else { return }
        
        updateTrackingState()
        
        if isWithinSafeZone(coordinate: location.coordinate) {
            logLocationToFirebase(location: location)
            checkForNearbyStructures(at: location)
        }
    }
    
    private func checkForNearbyStructures(at location: CLLocation) {
        if let nearestPoint = findNearestMapPoint(to: location.coordinate) {
            dataStore?.markStructureAsVisited(nearestPoint.landmark)
        }
    }
}

// MARK: - Private Helpers
private extension LocationService {
    func enableBackgroundTracking() {
        locationManager.allowsBackgroundLocationUpdates = true
        trackingState = .background
    }
    
    func disableBackgroundTracking() {
        locationManager.allowsBackgroundLocationUpdates = false
        trackingState = .inAppOnly
    }
    
    func logLocationToFirebase(location: CLLocation) {
        guard let nearestPoint = findNearestMapPoint(to: location.coordinate) else { return }
        
        let locationData: [String: Any] = [
            "latitude": nearestPoint.coordinate.latitude,
            "longitude": nearestPoint.coordinate.longitude,
            "timestamp": Timestamp(date: Date()),
            "userId": UserDefaults.standard.string(forKey: "localUserID") ?? UUID().uuidString
        ]
        
        firestoreRef.collection("user_locations").addDocument(data: locationData)
    }
    
    func findNearestMapPoint(to coordinate: CLLocationCoordinate2D) -> MapPoint? {
        var nearestPoint: MapPoint?
        var minDistance = Double.infinity
        
        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        guard let mapPoints = dataStore?.mapPoints else { return nil }
        
        for point in mapPoints {
            let pointLocation = CLLocation(
                latitude: point.coordinate.latitude,
                longitude: point.coordinate.longitude
            )
            let distance = userLocation.distance(from: pointLocation)
            if distance < minDistance {
                minDistance = distance
                nearestPoint = point
            }
        }
        
        return nearestPoint
    }
}

// MARK: - Enums
enum LocationMode {
    case initial
    case virtualTour
    case adventure
}

enum TrackingState {
    case inactive
    case inAppOnly
    case background
}
