//
//  LocationService.swift
//  PolyCanyon
//
//  Handles all location-related functionality including permissions, tracking, and geofencing.
//  It manages location updates in both foreground and background modes, coordinates with Firebase
//  for location logging, and provides location-based structure discovery. The service is available
//  app-wide as a shared singleton through environment objects (@EnvironmentObject) and closely
//  coordinates with AppState and DataStore.
//

import CoreLocation
import FirebaseFirestore
import Combine

// MARK: - Notifications
// These notifications can be used throughout the app to listen for location-related events.
extension Notification.Name {
    static let structureVisited = Notification.Name("structureVisited")
}

// MARK: - Enums
/// Represents the user's high-level state when in adventure mode, based on distance from the canyon.
enum AdventureLocationState {
    case notVisiting      // > 750m
    case onTheWay         // 750m > x > 370m
    case almostThere      // < 370m (background can start), not in canyon
    case exploring        // Within canyon boundaries
}

/// Indicates what kind of location mode the user/app is in.
enum LocationMode {
    case initial
    case virtualTour
    case adventure
}

/// Indicates the state of location tracking (i.e., whether we allow background tracking).
enum TrackingState {
    case inactive
    case inAppOnly
    case background
}

// MARK: - LocationService (Main Class)
class LocationService: NSObject, ObservableObject {
    // MARK: - Singleton
    static let shared = LocationService()
    
    // MARK: - Dependencies
    /// CoreLocation manager responsible for handling location updates.
    private let locationManager = CLLocationManager()
    
    /// Reference to Firestore for logging location updates.
    private lazy var firestoreRef: Firestore = {
        return Firestore.firestore()
    }()
    
    /// A set of AnyCancellable for Combine subscriptions if needed later.
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Map Points (Static Data)
    /// Loaded at initialization, these are all the map points from `mapPoints.json`.
    public private(set) var mapPoints: [MapPoint] = {
        guard let url = Bundle.main.url(forResource: "mapPoints", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let mapPointData = try? JSONDecoder().decode([MapPointData].self, from: data) else {
            print("⚠️ Failed to load mapPoints.json")
            return []
        }
        return mapPointData.map { MapPoint(from: $0) }
    }()
    
    // MARK: - Published States (For UI Binding)
    @Published private(set) var locationStatus: CLAuthorizationStatus?
    @Published private(set) var lastLocation: CLLocation?
    @Published private(set) var recommendedMode: Bool = false
    @Published private(set) var trackingState: TrackingState = .inactive
    @Published private(set) var adventureLocationState: AdventureLocationState = .notVisiting
    
    // MARK: - Internal State
    private var locationMode: LocationMode = .initial
    private var permissionContinuation: CheckedContinuation<Bool, Never>?
    
    /// The mode that is actually set for the user in the app (initial, virtualTour, adventure).
    @Published private(set) var currentMode: LocationMode = .initial
    
    // MARK: - Location Boundaries
    /// The approximate center point of Poly Canyon used for distance calculations.
    private let centerPoint = CLLocationCoordinate2D(
        latitude: 35.31583,
        longitude: -120.65347
    )
    
    /// Coordinates representing the bounding box for the canyon area.
    struct BoundaryCoordinates {
        static let topLeft = (latitude: 35.31658611111111, longitude: -120.6560599752971)
        static let topRight = (latitude: 35.31782413494509, longitude: -120.6541363709451)
        static let bottomLeft = (latitude: 35.31307, longitude: -120.65235)
        static let bottomRight = (latitude: 35.31431, longitude: -120.65065)
    }
    
    /// Radius for recommending adventure mode (~30 miles).
    private let recommendationRadius: CLLocationDistance = 28280
    
    /// Radius for enabling background updates (~370 meters).
    private let backgroundRadius: CLLocationDistance = 370
    
    /// Custom outer boundary (~750 meters).
    private let outerRadius: CLLocationDistance = 750
    
    // MARK: - Caching & Intervals
    private var lastMapPointCheck: Date?
    private var cachedNearestPoint: MapPoint?
    private let mapPointCheckInterval: TimeInterval = 1.0 // 1 second
    
    // MARK: - Mapping Structures to Map Points
    /// Maps each structure number to the index of its corresponding map point (minus 1 for the array index).
    private let structureToMapPointMapping: [Int: Int] = [
        1: 1,
        2: 3,
        3: 52,
        4: 53,
        5: 10,
        6: 11,
        7: 196,
        8: 13,
        9: 76,
        10: 16,
        11: 58,
        12: 19,
        13: 59,
        14: 21,
        15: 203,
        16: 24,
        17: 88,
        18: 91,
        19: 35,
        20: 113,
        21: 37,
        22: 32,
        23: 20,
        24: 57,
        25: 56,
        26: 44,
        27: 55,
        28: 60,
        29: 68,
        30: 199,
        31: 197
    ]
    
    // MARK: - Nearby Structures
    struct NearbyStructure: Identifiable, Equatable {
        let id = UUID()
        let structureNumber: Int
        let distance: CLLocationDistance
        let mapPoint: MapPoint
        
        static func == (lhs: NearbyStructure, rhs: NearbyStructure) -> Bool {
            return lhs.structureNumber == rhs.structureNumber
        }
    }
    
    // Add with other published properties
    @Published private(set) var nearbyStructures: [NearbyStructure] = []
    
    // MARK: - Initialization
    private override init() {
        super.init()
        print("📱 LocationService initialized")
        setupLocationManager()
    }
    
    /// Call this once the rest of the app is set up (e.g., from AppState) to finalize configs if needed.
    func configure() {
        print("📱 LocationService configured")
    }
    
    // MARK: - Setup
    /// Configure the location manager with desired accuracy, delegate, etc.
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    // MARK: - Permission Logic
    /// Requests the user’s initial when-in-use permission (usually during onboarding).
    func requestInitialPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            self.permissionContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
            
            // Start updating location immediately after requesting permission
            locationManager.startUpdatingLocation()
        }
    }
    
    /// Request "always" authorization for background tracking if needed.
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    /// Switch to a specified mode (adventure or virtualTour, etc.) and handle permission upgrades.
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
    
    /// Internal helper for requesting location permission based on mode.
    private func requestLocationPermission(for mode: LocationMode) {
        switch mode {
        case .adventure, .virtualTour:
            locationManager.requestWhenInUseAuthorization()
        case .initial:
            break
        }
    }
    
    // MARK: - Location Updates Control
    /// Start tracking location updates (foreground).
    private func startLocationUpdates() {
        locationManager.startUpdatingLocation()
        updateTrackingState()
    }
    
    /// Stop all location updates.
    private func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        trackingState = .inactive
    }
    
    /// Check if we should enable background location updates, then update tracking state.
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
    }
    
    // MARK: - Tracking Logic
    /// Called whenever the user toggles adventure mode on/off.
    func handleAdventureModeChange(_ isEnabled: Bool) {
        print("📱 Handling adventure mode change: \(isEnabled)")
        if isEnabled {
            startLocationUpdates()
        } else {
            stopLocationUpdates()
        }
    }
    
    /// Update the user’s `adventureLocationState` (e.g., notVisiting, onTheWay, almostThere, exploring).
    private func updateAdventureState(_ location: CLLocation) {
        guard currentMode == .adventure else { return }
        
        let distance = location.distance(
            from: CLLocation(latitude: centerPoint.latitude,
                             longitude: centerPoint.longitude)
        )
        
        if isWithinCanyon(location) {
            adventureLocationState = .exploring
        } else if isWithinBackgroundRange(location) {
            // < 370m
            adventureLocationState = .almostThere
        } else if distance <= outerRadius {
            // < 750m
            adventureLocationState = .onTheWay
        } else {
            adventureLocationState = .notVisiting
        }
        
        print("📍 ADVENTURE STATE: \(adventureLocationState)")
    }
    
    // MARK: - Public Methods
    /// Returns true if the user is within the "recommendationRadius" of the canyon center.
    func getRecommendedMode(_ location: CLLocation) -> Bool {
        return isWithinRecommendationRange(location)
    }
    
    /// Returns the distance from the user's last location to a specific structure.
    func getDistance(to structure: Structure) -> CLLocationDistance {
        guard let userLocation = lastLocation,
              let structurePoint = mapPoints.first(where: { $0.structure == structure.number }) else {
            return .infinity
        }
        
        let structureLocation = CLLocation(
            latitude: structurePoint.coordinate.latitude,
            longitude: structurePoint.coordinate.longitude
        )
        return userLocation.distance(from: structureLocation)
    }
    
    /// Checks if the user’s permission is outright denied or restricted.
    var isLocationPermissionDenied: Bool {
        return locationStatus == .denied || locationStatus == .restricted
    }
    
    /// Checks if the user has at least `authorizedWhenInUse`.
    var hasLocationPermission: Bool {
        return locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways
    }
    
    /// Determines if the user can actually use location inside the canyon.
    var canUseLocation: Bool {
        guard let location = lastLocation else { return false }
        return hasLocationPermission && isWithinCanyon(location)
    }
    
    /// Checks if the user is within the "backgroundRadius" but **not** in the canyon.
    var isNearby: Bool {
        guard let location = lastLocation,
              currentMode == .adventure else {
            print("📍 NEARBY CHECK: Failed - mode: \(currentMode)")
            return false
        }
        let inRange = isWithinBackgroundRange(location)
        let notInCanyon = !isWithinCanyon(location)
        print("📍 NEARBY CHECK: In range: \(inRange), Not in canyon: \(notInCanyon)")
        return inRange && notInCanyon
    }
    
    /// Checks if the user is "out of range" (> 370m) in adventure mode.
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
    
    /// Checks if the user is within the canyon bounding box.
    var isInPolyCanyonArea: Bool {
        guard let location = lastLocation,
              currentMode == .adventure else {
            print("📍 IN AREA CHECK: Failed guard - location: \(lastLocation != nil), adventure mode: \(currentMode)")
            return false
        }
        let result = isWithinCanyon(location)
        print("📍 IN AREA CHECK: \(result)")
        return result
    }
    
    /// Retrieves a `MapPoint` for a given structure number (if available).
    func getMapPointForStructure(_ structureNumber: Int) -> MapPoint? {
        guard let mapPointIndex = structureToMapPointMapping[structureNumber] else { return nil }
        // Subtract 1 since array is 0-based but our mapping is 1-based
        let arrayIndex = mapPointIndex - 1
        guard arrayIndex >= 0 && arrayIndex < mapPoints.count else { return nil }
        return mapPoints[arrayIndex]
    }
    
    /// Returns the 3 closest structures to the user's current location
    func updateNearbyStructures() {
        guard let userLocation = lastLocation else {
            nearbyStructures = []
            return
        }
        
        let structuresWithDistances = structureToMapPointMapping.compactMap { (structureNumber, mapPointIndex) -> NearbyStructure? in
            let arrayIndex = mapPointIndex - 1
            guard arrayIndex >= 0, arrayIndex < mapPoints.count else { return nil }
            
            let point = mapPoints[arrayIndex]
            let pointLocation = CLLocation(
                latitude: point.coordinate.latitude,
                longitude: point.coordinate.longitude
            )
            
            return NearbyStructure(
                structureNumber: structureNumber,
                distance: userLocation.distance(from: pointLocation),
                mapPoint: point
            )
        }
        .sorted { $0.distance < $1.distance }
        
        nearbyStructures = Array(structuresWithDistances.prefix(3))
    }
    
    // MARK: - Private Helpers
    /// Enable background location updates.
    private func enableBackgroundTracking() {
        locationManager.allowsBackgroundLocationUpdates = true
        trackingState = .background
    }
    
    /// Disable background location updates.
    private func disableBackgroundTracking() {
        locationManager.allowsBackgroundLocationUpdates = false
        trackingState = .inAppOnly
    }
    
    /// Log location to Firebase, attaching the nearest map point.
    private func logLocationToFirebase(location: CLLocation) {
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

// MARK: - Location Checks (Extension)
extension LocationService {
    /// Check if within ~30 miles of the center point to recommend adventure mode.
    func isWithinRecommendationRange(_ location: CLLocation) -> Bool {
        let centerLocation = CLLocation(latitude: centerPoint.latitude, longitude: centerPoint.longitude)
        return location.distance(from: centerLocation) <= recommendationRadius
    }
    
    /// Check if within ~370 meters of the center point to enable background updates.
    func isWithinBackgroundRange(_ location: CLLocation) -> Bool {
        let centerLocation = CLLocation(latitude: centerPoint.latitude, longitude: centerPoint.longitude)
        let distance = location.distance(from: centerLocation)
        print("📍 BACKGROUND RANGE CHECK: Distance \(distance) vs Limit \(backgroundRadius)")
        return distance <= backgroundRadius
    }
    
    /// Find the nearest `MapPoint` to a given coordinate. Caches results to avoid frequent lookups.
    func findNearestMapPoint(to coordinate: CLLocationCoordinate2D) -> MapPoint? {
        let now = Date()
        
        // Return cached point if within time interval
        if let lastCheck = lastMapPointCheck,
           now.timeIntervalSince(lastCheck) < mapPointCheckInterval {
            return cachedNearestPoint
        }
        
        // Otherwise, recalculate
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
    
    /// Check if a coordinate is within the bounding box of the canyon.
    func isWithinCanyon(coordinate: CLLocationCoordinate2D) -> Bool {
        let minLatitude  = BoundaryCoordinates.bottomLeft.latitude
        let maxLatitude  = BoundaryCoordinates.topRight.latitude
        let minLongitude = BoundaryCoordinates.topLeft.longitude
        let maxLongitude = BoundaryCoordinates.bottomRight.longitude
        
        let isWithinLatitude = (coordinate.latitude >= minLatitude && coordinate.latitude <= maxLatitude)
        let isWithinLongitude = (coordinate.longitude >= minLongitude && coordinate.longitude <= maxLongitude)
        
        return isWithinLatitude && isWithinLongitude
    }
    
    /// Convenience for `isWithinCanyon(coordinate:)` but takes a `CLLocation`.
    func isWithinCanyon(_ location: CLLocation) -> Bool {
        let result = isWithinCanyon(coordinate: location.coordinate)
        print("📍 CANYON CHECK: \(result)")
        return result
    }
}

// MARK: - CLLocationManagerDelegate (Extension)
extension LocationService: CLLocationManagerDelegate {
    /// Called when the authorization status changes (e.g., user grants or denies permission).
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
    
    /// Called whenever there are new location updates from CoreLocation.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("📍 LOCATION UPDATE: \(location.coordinate)")
        lastLocation = location
        
        print("📍 CURRENT MODE: \(currentMode)")
        print("📍 BACKGROUND RANGE: \(isWithinBackgroundRange(location))")
        print("📍 IN CANYON: \(isWithinCanyon(location))")
        
        recommendedMode = isWithinRecommendationRange(location)
        
        if permissionContinuation != nil {
            permissionContinuation?.resume(returning: true)
            permissionContinuation = nil
        }
        
        guard currentMode == .adventure else { return }
        
        // Update state before other checks
        updateAdventureState(location)
        updateTrackingState()
        
        // If we’re actually within the canyon, log the user and check for structures.
        if isWithinCanyon(location) {
            logLocationToFirebase(location: location)
            checkForNearbyStructures(at: location)
            updateNearbyStructures()
        }
    }
    
    /// Check for the nearest structure and post a notification if the user is close enough.
    private func checkForNearbyStructures(at location: CLLocation) {
        if let nearestPoint = findNearestMapPoint(to: location.coordinate),
           nearestPoint.structure != -1 {  // Only notify for valid structure points
            NotificationCenter.default.post(
                name: .structureVisited,
                object: nil,
                userInfo: ["structureNumber": nearestPoint.structure]
            )
        }
    }
}
