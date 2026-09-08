//
//  LocationService.swift
//  PolyCanyon
//
//  Handles all location-related functionality including permissions, tracking, and geofencing.
//  It manages location updates in both foreground and background modes and provides
//  location-based structure discovery. The service is available
//  app-wide as a shared singleton through environment objects (@EnvironmentObject) and closely
//  coordinates with AppState and DataStore.
//

import CoreLocation
import Combine

/// The service owns decisions; this boundary contains only Core Location hardware operations.
@MainActor
protocol LocationManaging: AnyObject {
    var delegate: CLLocationManagerDelegate? { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    var desiredAccuracy: CLLocationAccuracy { get set }
    var distanceFilter: CLLocationDistance { get set }
    var pausesLocationUpdatesAutomatically: Bool { get set }
    var allowsBackgroundLocationUpdates: Bool { get set }
    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

extension CLLocationManager: LocationManaging {}

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
@MainActor
final class LocationService: NSObject, ObservableObject {
    // MARK: - Singleton
    static let shared = LocationService()
    
    // MARK: - Dependencies
    /// CoreLocation manager responsible for handling location updates.
    private let locationManager: LocationManaging
    private let defaults: UserDefaults
    private let notifications: NotificationCenter
    private let now: () -> Date
    
    
    // MARK: - Map Points (Static Data)
    /// Loaded at initialization, these are all the map points from `mapPoints.json`.
    public private(set) var mapPoints: [MapPoint]

    private static func loadMapPoints(bundle: Bundle) -> [MapPoint] {
        guard let url = bundle.url(forResource: "mapPoints", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let mapPointData = try? JSONDecoder().decode([MapPointData].self, from: data) else {
            print("⚠️ Failed to load mapPoints.json")
            return []
        }
        return mapPointData.map { MapPoint(from: $0) }
    }
    
    // MARK: - Published States (For UI Binding)
    @Published private(set) var locationStatus: CLAuthorizationStatus?
    @Published private(set) var lastLocation: CLLocation?
    @Published private(set) var recommendedMode: Bool = false
    @Published private(set) var trackingState: TrackingState = .inactive
    @Published private(set) var adventureLocationState: AdventureLocationState = .notVisiting
    
    // MARK: - Internal State
    private var wantsUpdates = false
    private var isAppActive = true
    private var isUpdatingLocation = false
    
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
    
    /// Radius for recommending adventure mode (~28 kilometers).
    private let recommendationRadius: CLLocationDistance = 28280
    
    /// Radius for enabling background updates (~370 meters).
    private let backgroundRadius: CLLocationDistance = 370
    
    /// Custom outer boundary (~750 meters).
    private let outerRadius: CLLocationDistance = 750
    
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
        var id: Int { structureNumber }
        let structureNumber: Int
        let distance: CLLocationDistance
        let mapPoint: MapPoint
        
        static func == (lhs: NearbyStructure, rhs: NearbyStructure) -> Bool {
            return lhs.structureNumber == rhs.structureNumber && lhs.distance == rhs.distance
        }
    }
    
    // Add with other published properties
    @Published private(set) var nearbyStructures: [NearbyStructure] = []
    
    // Add this with other properties at the top
    private var lastLocationUpdate: Date?
    private let minimumUpdateInterval: TimeInterval = 1.5
    
    // MARK: - Initialization
    init(manager: LocationManaging = CLLocationManager(), bundle: Bundle = .main,
         defaults: UserDefaults = .standard, notifications: NotificationCenter = .default,
         now: @escaping () -> Date = Date.init) {
        locationManager = manager
        self.defaults = defaults
        self.notifications = notifications
        self.now = now
        mapPoints = Self.loadMapPoints(bundle: bundle)
        super.init()
        setupLocationManager()
    }
    
    /// Call this once the rest of the app is set up (e.g., from AppState) to finalize configs if needed.
    func configure() {
        if defaults.bool(forKey: "onboardingProcess") {
            setMode(defaults.bool(forKey: "adventureMode") ? .adventure : .virtualTour)
        } else if locationManager.authorizationStatus == .authorizedWhenInUse ||
                    locationManager.authorizationStatus == .authorizedAlways {
            setMode(.initial)
        }
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
    /// Requests the user's initial when-in-use permission (usually during onboarding).
    func requestInitialPermission() {
        wantsUpdates = true
        locationManager.requestWhenInUseAuthorization()
        updateTrackingState()
    }

    /// Request "always" authorization for background tracking if needed.
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    /// Switch to a specified mode (adventure or virtualTour, etc.) and handle permission upgrades.
    func setMode(_ mode: LocationMode) {
        currentMode = mode
        wantsUpdates = mode != .virtualTour
        if mode == .adventure { locationManager.requestWhenInUseAuthorization() }
        if mode == .virtualTour { clearLocation() }
        updateTrackingState()
    }

    /// Onboarding and distant adventures need no background GPS. Foregrounding resumes the selected mode.
    func setAppActive(_ active: Bool) {
        isAppActive = active
        if active {
            locationStatus = locationManager.authorizationStatus
            if !hasLocationPermission || lastLocation.map({ !LocationSamplePolicy.isUsable($0, now: now()) }) == true {
                clearLocation()
            }
        }
        updateTrackingState()
    }

    private func updateTrackingState() {
        let canTrackInBackground = currentMode == .adventure &&
            lastLocation.map { LocationSamplePolicy.isUsable($0, now: now()) && isWithinBackgroundRange($0) } == true
        let shouldRun = wantsUpdates && hasLocationPermission && (isAppActive || canTrackInBackground)
        let background = shouldRun && canTrackInBackground
        if locationManager.allowsBackgroundLocationUpdates != background {
            locationManager.allowsBackgroundLocationUpdates = background
        }
        if shouldRun != isUpdatingLocation {
            if shouldRun { locationManager.startUpdatingLocation() }
            else { locationManager.stopUpdatingLocation() }
            isUpdatingLocation = shouldRun
        }
        let next: TrackingState = !shouldRun ? .inactive : (background ? .background : .inAppOnly)
        if trackingState != next { trackingState = next }
    }

    private func clearLocation() {
        lastLocation = nil
        lastLocationUpdate = nil
        nearbyStructures = []
        recommendedMode = false
        adventureLocationState = .notVisiting
    }

    // MARK: - Tracking Logic
    /// Called whenever the user toggles adventure mode on/off.
    func handleAdventureModeChange(_ isEnabled: Bool) {
        setMode(isEnabled ? .adventure : .virtualTour)
    }
    
    /// Update the user's `adventureLocationState` (e.g., notVisiting, onTheWay, almostThere, exploring).
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
    
    /// Checks if the user's permission is outright denied or restricted.
    var isLocationPermissionDenied: Bool {
        return locationStatus == .denied || locationStatus == .restricted
    }
    
    /// Checks if the user has at least `authorizedWhenInUse`.
    var hasLocationPermission: Bool {
        return locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways
    }
    
    /// Determines if the user can actually use location inside the canyon.
    var canUseLocation: Bool {
        guard let location = lastLocation, LocationSamplePolicy.isUsable(location, now: now()) else { return false }
        return hasLocationPermission && isWithinCanyon(location)
    }
    
    /// Checks if the user is within the "backgroundRadius" but **not** in the canyon.
    var isNearby: Bool {
        guard let location = lastLocation,
              currentMode == .adventure else {
            return false
        }
        let inRange = isWithinBackgroundRange(location)
        let notInCanyon = !isWithinCanyon(location)
        return inRange && notInCanyon
    }
    
    /// Checks if the user is "out of range" (> 370m) in adventure mode.
    var isOutOfRange: Bool {
        guard let location = lastLocation,
              currentMode == .adventure else {
            return false
        }
        let result = !isWithinBackgroundRange(location)
        return result
    }
    
    /// Checks if the user is within the canyon bounding box.
    var isInPolyCanyonArea: Bool {
        guard let location = lastLocation, LocationSamplePolicy.isUsable(location, now: now()) else {
            return false
        }
        let result = isWithinCanyon(location)
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
    
    /// Reset session state without changing the OS authorization or writing application preferences.
    func reset() {
        wantsUpdates = false
        currentMode = .initial
        clearLocation()
        updateTrackingState()
    }
}

// MARK: - Location Checks (Extension)
extension LocationService {
    /// Check if within ~28 kilometers of the center point to recommend adventure mode.
    func isWithinRecommendationRange(_ location: CLLocation) -> Bool {
        let centerLocation = CLLocation(latitude: centerPoint.latitude, longitude: centerPoint.longitude)
        return location.distance(from: centerLocation) <= recommendationRadius
    }
    
    /// Check if within ~370 meters of the center point to enable background updates.
    func isWithinBackgroundRange(_ location: CLLocation) -> Bool {
        let centerLocation = CLLocation(latitude: centerPoint.latitude, longitude: centerPoint.longitude)
        let distance = location.distance(from: centerLocation)
        return distance <= backgroundRadius
    }
    
    /// The catalog is small; querying it directly avoids stale coordinate-dependent cache results.
    func findNearestMapPoint(to coordinate: CLLocationCoordinate2D) -> MapPoint? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return mapPoints.min {
            location.distance(from: CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)) <
            location.distance(from: CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude))
        }
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
        return result
    }
}

// MARK: - CLLocationManagerDelegate (Extension)
extension LocationService: @preconcurrency CLLocationManagerDelegate {
    /// Called when the authorization status changes (e.g., user grants or denies permission).
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        refreshAuthorization()
    }

    func refreshAuthorization() {
        locationStatus = locationManager.authorizationStatus
        if !hasLocationPermission { clearLocation() }
        updateTrackingState()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as? CLError)?.code == .denied {
            locationStatus = .denied
            clearLocation()
            updateTrackingState()
        }
    }

    /// Called whenever there are new location updates from CoreLocation.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        receiveLocations(locations)
    }

    func receiveLocations(_ locations: [CLLocation]) {
        guard isUpdatingLocation, currentMode != .virtualTour, hasLocationPermission,
              let location = locations.last,
              LocationSamplePolicy.isUsable(location, now: now()) else { return }
        
        let receiptTime = now()
        if let lastUpdate = lastLocationUpdate, 
           receiptTime.timeIntervalSince(lastUpdate) < minimumUpdateInterval {
            return
        }
        
        lastLocationUpdate = receiptTime
        lastLocation = location
        
        recommendedMode = isWithinRecommendationRange(location)
        
        
        guard currentMode == .adventure else { return }
        
        updateAdventureState(location)
        updateTrackingState()
        
        if isWithinCanyon(location) && LocationSamplePolicy.canAwardVisit(location, now: now()) {
            checkForNearbyStructures(at: location)
            updateNearbyStructures()
        } else {
            nearbyStructures = []
        }
    }
    
    /// Check for the nearest structure and post a notification if the user is close enough.
    private func checkForNearbyStructures(at location: CLLocation) {
        if let nearestPoint = findNearestMapPoint(to: location.coordinate),
           nearestPoint.structure != -1 {  // Only notify for valid structure points
            notifications.post(
                name: .structureVisited,
                object: nil,
                userInfo: ["structureNumber": nearestPoint.structure]
            )
        }
    }
}
