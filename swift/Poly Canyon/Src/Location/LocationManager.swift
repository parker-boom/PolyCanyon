// MARK: LocationManager.swift

import Foundation
import CoreLocation
import Combine
import FirebaseFirestore
import FirebaseAuth

/**
 * LocationManager
 *
 * Manages location services for the Poly Canyon app, including tracking user location,
 * handling authorization status, logging locations to Firebase, and managing user interactions
 * with map points and structures. It supports both foreground and background location updates
 * based on the Adventure Mode status.
 */
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var mapPointManager: MapPointManager
    private var structureData: StructureData
    private var lastLoggedMapPoint: MapPoint?
    private var firestoreRef: Firestore!
    private var userID: String

    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var nearestMapPoint: MapPoint?
    @Published var isBackgroundTrackingActive = false
    private var previousDayVisited: String? = UserDefaults.standard.string(forKey: "previousDayVisited")

    @Published var isAdventureModeEnabled: Bool {
        didSet {
            updateLocationTracking()
        }
    }

    private let safeZoneCorners = (
        bottomLeft: CLLocationCoordinate2D(latitude: 35.31214, longitude: -120.65529),
        topRight: CLLocationCoordinate2D(latitude: 35.31813, longitude: -120.65110)
    )

    /**
     * Initializes the LocationManager with necessary managers and Adventure Mode status.
     * Sets up location manager configurations and Firebase references.
     *
     * - Parameters:
     *   - mapPointManager: Manages map points within the app.
     *   - structureData: Handles data related to structures in Poly Canyon.
     *   - isAdventureModeEnabled: Indicates if Adventure Mode is active.
     */
    init(mapPointManager: MapPointManager, structureData: StructureData, isAdventureModeEnabled: Bool) {
        self.mapPointManager = mapPointManager
        self.structureData = structureData
        self.isAdventureModeEnabled = isAdventureModeEnabled

        // Generate or retrieve the user ID
        if let savedUserID = UserDefaults.standard.string(forKey: "localUserID") {
            self.userID = savedUserID
        } else {
            self.userID = UUID().uuidString
            UserDefaults.standard.set(self.userID, forKey: "localUserID")
        }

        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = false // Initially disable background updates

        firestoreRef = Firestore.firestore()

        updateLocationTracking()
    }

    /**
     * Updates location tracking based on the Adventure Mode status.
     * Starts or stops location updates and background tracking accordingly.
     */
    private func updateLocationTracking() {
        print("Updating location tracking. Adventure Mode: \(isAdventureModeEnabled)")

        if isAdventureModeEnabled {
            startUpdatingLocation()
        } else {
            stopAllTracking()
        }
    }

    /**
     * Requests always authorization for location services.
     */
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
        logLocationChange(message: "Requested Always Authorization")
    }

    /**
     * Requests when-in-use authorization for location services.
     */
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
        logLocationChange(message: "Requested When In Use Authorization")
    }

    /**
     * Starts updating the user's location.
     */
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        logLocationChange(message: "Started updating location")
    }

    /**
     * Stops all location tracking activities, including background tracking.
     */
    private func stopAllTracking() {
        locationManager.stopUpdatingLocation()
        stopBackgroundTracking()
        logLocationChange(message: "All location tracking stopped")
    }

    /**
     * Starts background location tracking if not already active.
     */
    private func startBackgroundTracking() {
        guard !isBackgroundTrackingActive else {
            print("Background tracking is already active.")
            return
        }
        locationManager.allowsBackgroundLocationUpdates = true
        isBackgroundTrackingActive = true
        logLocationChange(message: "Background location tracking started")
    }

    /**
     * Stops background location tracking if it is active.
     */
    private func stopBackgroundTracking() {
        guard isBackgroundTrackingActive else {
            print("Background tracking is already inactive.")
            return
        }
        locationManager.allowsBackgroundLocationUpdates = false
        isBackgroundTrackingActive = false
        logLocationChange(message: "Background location tracking stopped")
    }

    /**
     * Logs location-related messages for debugging purposes.
     *
     * - Parameter message: The message to log.
     */
    private func logLocationChange(message: String) {
        print("[LocationManager] \(message)")
    }

    // MARK: CLLocationManagerDelegate Methods

    /**
     * Handles changes in location authorization status.
     *
     * - Parameter manager: The CLLocationManager instance.
     */
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            logLocationChange(message: "Location access granted: \(manager.authorizationStatus.rawValue)")
            updateLocationTracking()
        case .denied, .restricted:
            logLocationChange(message: "Location access denied or restricted.")
            stopAllTracking()
        case .notDetermined:
            logLocationChange(message: "Location status not determined.")
        @unknown default:
            logLocationChange(message: "Unknown location authorization status.")
        }
    }

    /**
     * Receives updated location data and handles logging and map point updates.
     *
     * - Parameters:
     *   - manager: The CLLocationManager instance.
     *   - locations: An array of CLLocation objects representing updated locations.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        lastLocation = location
        logLocationChange(message: "Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        logLocationToFirebaseIfNeeded(location: location)
        updateNearestMapPoint(for: location)

        let withinSafeZone = isWithinSafeZone(coordinate: location.coordinate)
        print("User is within safe zone: \(withinSafeZone)")

        if isAdventureModeEnabled {
            if withinSafeZone {
                if !isBackgroundTrackingActive {
                    startBackgroundTracking()
                }
                checkVisitedLandmarks()
            } else {
                if isBackgroundTrackingActive {
                    stopBackgroundTracking()
                }
            }
        }
    }

    /**
     * Logs the user's location to Firebase if Adventure Mode is enabled and within the safe zone.
     *
     * - Parameter location: The CLLocation object representing the user's current location.
     */
    private func logLocationToFirebaseIfNeeded(location: CLLocation) {
        // Check if Adventure Mode is enabled
        guard isAdventureModeEnabled else {
            print("Adventure mode is disabled, not logging location.")
            return
        }

        // Check if the user is within the safe zone
        guard isWithinSafeZone(coordinate: location.coordinate) else {
            print("User is not within the safe zone, not logging location.")
            return
        }

        // Find the nearest map point
        guard let newMapPoint = findNearestMapPoint(to: location.coordinate),
              newMapPoint != lastLoggedMapPoint else {
            print("Map point has not changed, not logging location.")
            return
        }

        // Log the map point coordinates (not the user's exact location)
        let locationData: [String: Any] = [
            "latitude": newMapPoint.coordinate.latitude,
            "longitude": newMapPoint.coordinate.longitude,
            "timestamp": Timestamp(date: Date()),
            "userId": userID
        ]

        firestoreRef.collection("user_locations").addDocument(data: locationData) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Location logged to Firebase for map point: \(newMapPoint)")
            }
        }

        // Update the last logged map point
        lastLoggedMapPoint = newMapPoint
    }

    /**
     * Finds the nearest map point to the given coordinate.
     *
     * - Parameter coordinate: The CLLocationCoordinate2D to find the nearest map point to.
     * - Returns: The nearest MapPoint object, if any.
     */
    private func findNearestMapPoint(to coordinate: CLLocationCoordinate2D) -> MapPoint? {
        var nearestPoint: MapPoint?
        var minDistance = Double.infinity
        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        for point in mapPointManager.mapPoints {
            let pointLocation = CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
            let distance = userLocation.distance(from: pointLocation)
            if distance < minDistance {
                minDistance = distance
                nearestPoint = point
            }
        }
        return nearestPoint
    }

    /**
     * Updates the nearest map point based on the user's current location.
     *
     * - Parameter location: The CLLocation object representing the user's current location.
     */
    private func updateNearestMapPoint(for location: CLLocation) {
        nearestMapPoint = findNearestMapPoint(to: location.coordinate)
    }

    // MARK: Landmark Functions

    /**
     * Checks proximity to landmarks and marks the nearest one as visited if applicable.
     */
    private func checkVisitedLandmarks() {
        guard let userLocation = lastLocation else { return }

        print("DEBUG: Checking visited landmarks")

        var nearestMapPoint: MapPoint?
        var minDistance = Double.infinity

        for mapPoint in mapPointManager.mapPoints {
            let distance = userLocation.distance(from: CLLocation(latitude: mapPoint.coordinate.latitude, longitude: mapPoint.coordinate.longitude))
            if distance < minDistance {
                minDistance = distance
                nearestMapPoint = mapPoint
            }
        }

        if let nearestPoint = nearestMapPoint {
            print("DEBUG: Nearest point - Landmark: \(nearestPoint.landmark), Distance: \(minDistance)")

            if nearestPoint.landmark != -1 {
                print("DEBUG: Checking visited status for structure \(nearestPoint.landmark)")
                let isVisited = structureData.checkVisitedStatus(index: nearestPoint.landmark - 1)  // Adjust index
                print("DEBUG: Structure \(nearestPoint.landmark) visited status: \(isVisited)")

                if !isVisited {
                    print("DEBUG: Marking structure \(nearestPoint.landmark) as visited")
                    nearestPoint.isVisited = true
                    mapPointManager.saveVisitedStatus()
                    markStructureAsVisited(nearestPoint.landmark)

                    // Check based on the landmark number and mark additional points as visited
                    switch nearestPoint.landmark {
                    case 7:
                        markPointAsVisitedByIndex(54)
                        markPointAsVisitedByIndex(196)
                    case 12:
                        markPointAsVisitedByIndex(19)
                        markPointAsVisitedByIndex(108)
                    case 13:
                        markPointAsVisitedByIndex(59)
                        markPointAsVisitedByIndex(80)
                    case 14:
                        markPointAsVisitedByIndex(21)
                        markPointAsVisitedByIndex(130)
                    case 16:
                        markPointAsVisitedByIndex(24)
                        markPointAsVisitedByIndex(132)
                    case 18:
                        markPointAsVisitedByIndex(26)
                        markPointAsVisitedByIndex(91)
                    case 20:
                        markPointAsVisitedByIndex(36)
                        markPointAsVisitedByIndex(113)
                    case 28:
                        markPointAsVisitedByIndex(49)
                        markPointAsVisitedByIndex(60)
                    case 29:
                        markPointAsVisitedByIndex(23)
                        markPointAsVisitedByIndex(50)
                    default:
                        break
                    }
                }
            }
        }
    }

    /**
     * Marks a specific map point as visited based on its index.
     *
     * - Parameter index: The index of the map point to mark as visited.
     */
    private func markPointAsVisitedByIndex(_ index: Int) {
        print("DEBUG: Marking additional point at index \(index) as visited")
        let mapPoints = mapPointManager.mapPoints
        if index >= 1 && index <= mapPoints.count { // Adjusted to 1-based index
            let newIndex = index - 1
            mapPoints[newIndex].isVisited = true
            markStructureAsVisited(mapPoints[newIndex].landmark)
            print("DEBUG: Additional point marked as visited - Landmark: \(mapPoints[newIndex].landmark)")
        } else {
            print("DEBUG: Invalid index for additional point: \(index)")
        }
    }

    /**
     * Marks a structure as visited and updates related counts and notifications.
     *
     * - Parameter landmarkId: The ID of the landmark to mark as visited.
     */
    private func markStructureAsVisited(_ landmarkId: Int) {
        NotificationCenter.default.post(name: .structureVisited, object: landmarkId)

        // Update day count
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: currentDate)

        if let lastVisited = self.previousDayVisited {
            if lastVisited != todayString {
                self.dayCount += 1
                self.previousDayVisited = todayString
                UserDefaults.standard.set(self.dayCount, forKey: "dayCount")
                UserDefaults.standard.set(todayString, forKey: "previousDayVisited")
            }
        } else {
            self.dayCount += 1
            self.previousDayVisited = todayString
            UserDefaults.standard.set(self.dayCount, forKey: "dayCount")
            UserDefaults.standard.set(todayString, forKey: "previousDayVisited")
        }

        // Notify observers of the updated day count
        objectWillChange.send()
    }

    /**
     * Checks if a given coordinate is within the predefined safe zone.
     *
     * - Parameter coordinate: The CLLocationCoordinate2D to check.
     * - Returns: A Boolean indicating whether the coordinate is within the safe zone.
     */
    public func isWithinSafeZone(coordinate: CLLocationCoordinate2D) -> Bool {
        let minLat = safeZoneCorners.bottomLeft.latitude
        let maxLat = safeZoneCorners.topRight.latitude
        let minLon = safeZoneCorners.bottomLeft.longitude
        let maxLon = safeZoneCorners.topRight.longitude

        let within = coordinate.latitude >= minLat && coordinate.latitude <= maxLat &&
                      coordinate.longitude >= minLon && coordinate.longitude <= maxLon

        print("Checking if coordinate (\(coordinate.latitude), \(coordinate.longitude)) is within safe zone: \(within)")
        return within
    }
}

extension Notification.Name {
    static let allStructuresVisited = Notification.Name("allStructuresVisited")
}
