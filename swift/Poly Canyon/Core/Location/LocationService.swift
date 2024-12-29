/*
 LocationService handles all location-related functionality including permissions, tracking, and geofencing.
 It manages location updates in both foreground and background modes, coordinates with Firebase for location
 logging, and provides location-based structure discovery. The service is available app-wide as a shared 
 singleton through environment objects (@EnvironmentObject) and closely coordinates with AppState and DataStore.
*/

import CoreLocation
import FirebaseFirestore
import Combine

class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    // MARK: - Dependencies
    private let locationManager = CLLocationManager()
    private var firestoreRef: Firestore!
    private var cancellables = Set<AnyCancellable>()
    private weak var appState: AppState?
    private weak var dataStore: DataStore?
    
    // MARK: - Published States
    @Published private(set) var locationStatus: CLAuthorizationStatus?
    @Published private(set) var lastLocation: CLLocation?
    @Published private(set) var recommendedMode: Bool = false
    @Published private(set) var trackingState: TrackingState = .inactive
    
    // MARK: - Internal State
    private var locationMode: LocationMode = .initial
    private var permissionContinuation: CheckedContinuation<Bool, Never>?
    
    
    // MARK: - Location Boundaries
    private let centerPoint = CLLocationCoordinate2D(
        latitude: 35.31461,
        longitude: -120.65238
    )
    
    private let safeZoneCorners = (
        bottomLeft: CLLocationCoordinate2D(latitude: 35.31214, longitude: -120.65529),
        topRight: CLLocationCoordinate2D(latitude: 35.31813, longitude: -120.65110)
    )
    
    private let recommendationRadius: CLLocationDistance = 48280  // 30 miles for mode recommendation
    private let backgroundRadius: CLLocationDistance = 1609.34   // 1 mile for background tracking
    
    // MARK: - Initialization
    private override init() {
        super.init()
        setupLocationManager()
        setupFirestore()
    }
    
    // Pull in app state and data store, to use them in the service
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
    
    // Setup Firebase
    private func setupFirestore() {
        firestoreRef = Firestore.firestore()
    }
    
    // MARK: - Public Permission Interface
    // Done in onboarding first time
    func requestInitialPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            self.permissionContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    /// Switch to specified mode and handle permission upgrades
    func setMode(_ mode: LocationMode) {
        locationMode = mode
        
        switch mode {
        case .adventure:
            requestLocationPermission(for: .adventure)
            startLocationUpdates()
        case .virtualTour:
            stopLocationUpdates()
        case .initial:
            break
        }
        
        // Persist mode selection
        UserDefaults.standard.set(mode == .adventure, forKey: "adventureMode")
    }
    
    // Make this private since setMode handles the public interface
    private func requestLocationPermission(for mode: LocationMode) {
        switch mode {
        case .adventure:
            locationManager.requestAlwaysAuthorization()
        case .virtualTour:
            locationManager.requestWhenInUseAuthorization()
        case .initial:
            break
        }
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
    
    // Update tracking if within background range
    private func updateTrackingState() {
        guard appState?.adventureModeEnabled == true,
              let location = lastLocation else {
            trackingState = .inactive
            return
        }
        
        // If within 1 mile, enable background tracking
        if isWithinBackgroundRange(location) {
            enableBackgroundTracking()

        // If not, disable background tracking
        } else {
            disableBackgroundTracking()
        }
    }
    
    // If authorization changes, update the mode
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
    
    // Distance between point & structures
    func getDistance(to structure: Structure) -> CLLocationDistance {
        guard let userLocation = lastLocation else { return .infinity }
        guard let structureLocation = dataStore?.mapPoints.first(where: { $0.landmark == structure.number })?.coordinate else {
            return .infinity
        }
        let structureCLLocation = CLLocation(
            latitude: structureLocation.latitude, 
            longitude: structureLocation.longitude
        )
        return userLocation.distance(from: structureCLLocation)
    }
    
    var isLocationPermissionDenied: Bool {
        return locationStatus == .denied || locationStatus == .restricted
    }
    
    var hasLocationPermission: Bool {
        return locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways
    }
    
    var canUseLocation: Bool {
        guard let location = lastLocation else { return false }
        return hasLocationPermission && isWithinSafeZone(coordinate: location.coordinate)
    }
}

// MARK: - Location Checks
extension LocationService {
    // Check if within 30 miles of center point
    func isWithinRecommendationRange(_ location: CLLocation) -> Bool {
        let centerLocation = CLLocation(
            latitude: centerPoint.latitude,
            longitude: centerPoint.longitude
        )
        return location.distance(from: centerLocation) <= recommendationRadius
    }

    // Check if within 1 mile of center point
    func isWithinBackgroundRange(_ location: CLLocation) -> Bool {
        let centerLocation = CLLocation(
            latitude: centerPoint.latitude,
            longitude: centerPoint.longitude
        )
        return location.distance(from: centerLocation) <= backgroundRadius
    }
    
    // Check if within safe zone (in map area)
    func isWithinSafeZone(_ location: CLLocation) -> Bool {
        return isWithinSafeZone(coordinate: location.coordinate)
    }
    
    // Check if within safe zone (in map area)
    func isWithinSafeZone(coordinate: CLLocationCoordinate2D) -> Bool {
        let isWithinLatitude = coordinate.latitude >= safeZoneCorners.bottomLeft.latitude &&
                              coordinate.latitude <= safeZoneCorners.topRight.latitude
        
        let isWithinLongitude = coordinate.longitude >= safeZoneCorners.bottomLeft.longitude &&
                               coordinate.longitude <= safeZoneCorners.topRight.longitude
        
        return isWithinLatitude && isWithinLongitude
    }
    
    // Find nearest map point to user
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

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    // If authorization changes, update the mode
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
    
    // If location updates, update the last location
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
    
    // If within safe zone, log location to firebase and check for nearby structures
    private func checkForNearbyStructures(at location: CLLocation) {
        if let nearestPoint = findNearestMapPoint(to: location.coordinate) {
            dataStore?.markStructureAsVisited(nearestPoint.landmark)
        }
    }
}

// MARK: - Private Helpers
private extension LocationService {
    // Enable background tracking
    func enableBackgroundTracking() {
        locationManager.allowsBackgroundLocationUpdates = true
        trackingState = .background
    }
    
    // Disable background tracking
    func disableBackgroundTracking() {
        locationManager.allowsBackgroundLocationUpdates = false
        trackingState = .inAppOnly
    }
    
    // Log location to firebase
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
