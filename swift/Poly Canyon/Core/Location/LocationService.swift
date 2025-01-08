/*
 LocationService handles all location-related functionality including permissions, tracking, and geofencing.
 It manages location updates in both foreground and background modes, coordinates with Firebase for location
 logging, and provides location-based structure discovery. The service is available app-wide as a shared 
 singleton through environment objects (@EnvironmentObject) and closely coordinates with AppState and DataStore.
*/

import CoreLocation
import FirebaseFirestore
import Combine

extension Notification.Name {
    static let structureVisited = Notification.Name("structureVisited")
}

class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    // MARK: - Dependencies
    private let locationManager = CLLocationManager()
    private lazy var firestoreRef: Firestore = {
        return Firestore.firestore()
    }()
    private var cancellables = Set<AnyCancellable>()

    // WILL NEED THIS LATER:
    /*
    struct BoundaryCoordinates {
    static let topLeft = (latitude: 35.31658611111111, longitude: -120.6560599752971)
    static let topRight = (latitude: 35.31782413494509, longitude: -120.6541363709451)
    static let bottomLeft = (latitude: 35.31277464042485, longitude: -120.6519863469588)
    static let bottomRight = (latitude: 35.31454021427865, longitude: -120.6509764049769)
    }
    */

    // Load MapPoints directly since they're fixed
    private var mapPoints: [MapPoint] = {
        guard let url = Bundle.main.url(forResource: "mapPoints", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let mapPointData = try? JSONDecoder().decode([MapPointData].self, from: data) else {
            print("⚠️ Failed to load mapPoints.json")
            return []
        }
        return mapPointData.map { MapPoint(from: $0) }
    }()
    
    // MARK: - Published States
    @Published private(set) var locationStatus: CLAuthorizationStatus?
    @Published private(set) var lastLocation: CLLocation?
    @Published private(set) var recommendedMode: Bool = false
    @Published private(set) var trackingState: TrackingState = .inactive
    
    // Computed states for UI
    @Published private(set) var locationMessage: LocationMessage?
    @Published private(set) var shouldShowLocationDot: Bool = false
    
    enum LocationMessage {
        case needsPermission
        case outOfRange
        case nearby
        case none
    }
    
    // MARK: - Internal State
    private var locationMode: LocationMode = .initial
    private var permissionContinuation: CheckedContinuation<Bool, Never>?
    
    @Published private(set) var currentMode: LocationMode = .initial
    
    // MARK: - Location Boundaries
    private let centerPoint = CLLocationCoordinate2D(
        latitude: 35.31461,
        longitude: -120.65238
    )
    
    private let safeZoneCorners = (
        bottomLeft: CLLocationCoordinate2D(latitude: 35.31214, longitude: -120.65529),
        topRight: CLLocationCoordinate2D(latitude: 35.31813, longitude: -120.65110)
    )
    
    private let recommendationRadius: CLLocationDistance = 28280 // SLO City Boundaries
    private let backgroundRadius: CLLocationDistance = 500.34 // Walking path bench spot
    
    // Add throttle time tracking
    private var lastStructureCheck: Date?
    private let structureCheckInterval: TimeInterval = 3.0 // 3 seconds
    
    // Add cached point and last check time
    private var lastMapPointCheck: Date?
    private var cachedNearestPoint: MapPoint?
    private let mapPointCheckInterval: TimeInterval = 3.0 // 3 seconds
    
    // MARK: - Initialization
    private override init() {
        super.init()
        print("📱 LocationService initialized")
        setupLocationManager()
    }
    
    // Pull in app state and data store, to use them in the service
    func configure() {
        print("📱 LocationService configured")
    }
    
    // MARK: - Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    // MARK: - Public Permission Interface
    // Done in onboarding first time
    func requestInitialPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            self.permissionContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
            
            // Start updating location immediately after requesting permission
            locationManager.startUpdatingLocation()
        }
    }
    
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    /// Switch to specified mode and handle permission upgrades
    func setMode(_ mode: LocationMode) {
        print("📱 Setting LocationService mode to: \(mode)")
        currentMode = mode
        
        switch mode {
        case .adventure:
            requestLocationPermission(for: .adventure)
            startLocationUpdates()
        case .virtualTour:
            stopLocationUpdates()
        case .initial:
            break
        }
    }
    
    // Make this private since setMode handles the public interface
    private func requestLocationPermission(for mode: LocationMode) {
        switch mode {
        case .adventure:
            locationManager.requestWhenInUseAuthorization()
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
        guard currentMode == .adventure,
              let location = lastLocation else {
            trackingState = .inactive
            return
        }
        
        if isWithinBackgroundRange(location) {
            enableBackgroundTracking()
        } else {
            disableBackgroundTracking()
        }
        
        // Update location message whenever tracking state changes
        updateLocationMessage()
    }
    
    // For onboarding recommendation only
    func getRecommendedMode(_ location: CLLocation) -> Bool {
        return isWithinRecommendationRange(location)
    }
    
    // Distance between point & structures
    func getDistance(to structure: Structure) -> CLLocationDistance {
        guard let userLocation = lastLocation,
              let structurePoint = mapPoints.first(where: { $0.landmark == structure.number }) else {
            return .infinity
        }
        
        let structureLocation = CLLocation(
            latitude: structurePoint.coordinate.latitude,
            longitude: structurePoint.coordinate.longitude
        )
        return userLocation.distance(from: structureLocation)
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
    
    var isNearby: Bool {
        guard let location = lastLocation,
              currentMode == .adventure else {
            print("📍 NEARBY CHECK: Failed - mode: \(currentMode)")
            return false
        }
        let inRange = isWithinBackgroundRange(location)
        let notInSafe = !isWithinSafeZone(location)
        print("📍 NEARBY CHECK: In range: \(inRange), Not in safe zone: \(notInSafe)")
        return inRange && notInSafe
    }
    
    // Status checks for map messages
    var isOutOfRange: Bool {
        guard let location = lastLocation,
              currentMode == .adventure else {
            print("📍 OUT OF RANGE CHECK: Failed guard - location: \(lastLocation != nil), adventure mode: \(currentMode)")
            return false
        }
        let result = !isWithinBackgroundRange(location)
        print("📍 OUT OF RANGE CHECK: \(result) - Distance from center: \(location.distance(from: CLLocation(latitude: centerPoint.latitude, longitude: centerPoint.longitude)))")
        return result
    }
    
    var isInPolyCanyonArea: Bool {
        guard let location = lastLocation,
              currentMode == .adventure else {
            print("📍 IN AREA CHECK: Failed guard - location: \(lastLocation != nil), adventure mode: \(currentMode)")
            return false
        }
        let result = isWithinSafeZone(location)
        print("📍 IN AREA CHECK: \(result)")
        return result
    }
    
    // Add this public method
    func handleAdventureModeChange(_ isEnabled: Bool) {
        print("📱 Handling adventure mode change: \(isEnabled)")
        if isEnabled {
            startLocationUpdates()
        } else {
            stopLocationUpdates()
        }
        updateLocationMessage()
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
        let distance = location.distance(from: centerLocation)
        print("📍 BACKGROUND RANGE CHECK: Distance \(distance) vs Limit \(backgroundRadius)")
        return distance <= backgroundRadius
    }
    
    // Check if within safe zone (in map area)
    func isWithinSafeZone(_ location: CLLocation) -> Bool {
        let result = isWithinSafeZone(coordinate: location.coordinate)
        print("📍 SAFE ZONE CHECK: \(result)")
        return result
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
        let now = Date()
        
        // Return cached point if within time interval
        if let lastCheck = lastMapPointCheck,
           now.timeIntervalSince(lastCheck) < mapPointCheckInterval {
            return cachedNearestPoint
        }
        
        // Otherwise recalculate
        guard !mapPoints.isEmpty else { return nil }
        
        var closestPoint: MapPoint?
        var minDistance = Double.infinity
        
        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        for point in mapPoints {
            let pointLocation = CLLocation(
                latitude: point.coordinate.latitude,
                longitude: point.coordinate.longitude
            )
            let distance = userLocation.distance(from: pointLocation)
            
            if distance < minDistance {
                minDistance = distance
                closestPoint = point
            }
        }
        
        // Update cache
        lastMapPointCheck = now
        cachedNearestPoint = closestPoint
        return closestPoint
    }
    
    private func checkForNearbyStructures(at location: CLLocation) {
        if let nearestPoint = findNearestMapPoint(to: location.coordinate),
           nearestPoint.landmark != -1 {  // Only notify for valid structure points
            NotificationCenter.default.post(
                name: .structureVisited,
                object: nil,
                userInfo: ["structureNumber": nearestPoint.landmark]
            )
        }
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
            
            if currentMode == .adventure {
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
        print("📍 LOCATION UPDATE: \(location.coordinate)")
        lastLocation = location
        
        print("📍 CURRENT MODE: \(currentMode)")
        print("📍 BACKGROUND RANGE: \(isWithinBackgroundRange(location))")
        print("📍 SAFE ZONE: \(isWithinSafeZone(location))")
        
        recommendedMode = isWithinRecommendationRange(location)
        
        if permissionContinuation != nil {
            permissionContinuation?.resume(returning: true)
            permissionContinuation = nil
        }
        
        guard currentMode == .adventure else { return }
        
        updateTrackingState()
        
        if isWithinSafeZone(coordinate: location.coordinate) {
            logLocationToFirebase(location: location)
            checkForNearbyStructures(at: location)
        }
    }
    
    // If within safe zone, log location to firebase and check for nearby structures
    private func checkForNearbyStructures(at location: CLLocation) {
        if let nearestPoint = findNearestMapPoint(to: location.coordinate),
           nearestPoint.landmark != -1 {  // Only notify for valid structure points
            NotificationCenter.default.post(
                name: .structureVisited,
                object: nil,
                userInfo: ["structureNumber": nearestPoint.landmark]
            )
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
    
    private func updateLocationMessage() {
        if isLocationPermissionDenied {
            locationMessage = .needsPermission
        } else if isOutOfRange {
            locationMessage = .outOfRange
        } else if isNearby {
            locationMessage = .nearby
        } else {
            locationMessage = .none
        }
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

extension Array {
    func binarySearch(_ isOrderedBefore: (Element) -> ComparisonResult) -> Int {
        var lowerBound = 0
        var upperBound = count
        
        while lowerBound < upperBound {
            let midIndex = (lowerBound + upperBound) / 2
            switch isOrderedBefore(self[midIndex]) {
            case .orderedAscending:
                lowerBound = midIndex + 1
            case .orderedDescending:
                upperBound = midIndex
            case .orderedSame:
                return midIndex
            }
        }
        
        return lowerBound
    }
}

