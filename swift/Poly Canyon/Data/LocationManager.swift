// MARK: LocationManager.swift
/*
    LocationManager.swift

    This file defines the LocationManager class, which manages location services and tracks user location relative to predefined landmarks.

    Key Components:
    - CLLocationManager for handling location updates and permissions.
    - MapPointManager and StructureData for managing map points and structure data.
    - Publishes location status and the last known location.

    Functionality:
    - Requests location authorization and starts location updates.
    - Checks if the user is within a predefined safe zone and adjusts location update frequency.
    - Monitors significant location changes and sets up a geofence for the safe zone.
    - Marks landmarks as visited based on user location and proximity.
    - Handles entering and exiting the safe zone region with appropriate location update adjustments.

    Additional Functions:
    - `requestAlwaysAuthorization()`: Requests "Always" location authorization.
    - `markStructureAsVisited(landmarkId: Int)`: Posts a notification when a structure is visited.
    - `isWithinSafeZone(coordinate: CLLocationCoordinate2D)`: Checks if a coordinate is within the safe zone.
*/




// MARK: Code
import Foundation
import CoreLocation
import Combine
import FirebaseFirestore
import FirebaseAuth



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
    @Published var dayCount: Int = UserDefaults.standard.integer(forKey: "dayCount")
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
        locationManager.allowsBackgroundLocationUpdates = true
        
        firestoreRef = Firestore.firestore()
        
        setupGeofenceForSafeZone()
        updateLocationTracking()
    }
    

    private func updateLocationTracking() {
        if isAdventureModeEnabled {
            startLocationUpdates()
        } else {
            stopAllTracking()
        }
    }
    
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
        logLocationChange(message: "Requested Always Authorization")
    }

    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
        logLocationChange(message: "Requested When In Use Authorization")
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        logLocationChange(message: "Started updating location")
    }

    private func startLocationUpdates() {
        if isAdventureModeEnabled {
            startUpdatingLocation()
            if let location = lastLocation, isWithinSafeZone(coordinate: location.coordinate) {
                startBackgroundTracking()
            }
        }
    }

    private func stopAllTracking() {
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        isBackgroundTrackingActive = false
        logLocationChange(message: "All location tracking stopped")
    }

    private func startBackgroundTracking() {
        guard !isBackgroundTrackingActive else { return }
        locationManager.allowsBackgroundLocationUpdates = true
        isBackgroundTrackingActive = true
        logLocationChange(message: "Background location tracking started")
    }

    private func stopBackgroundTracking() {
        guard isBackgroundTrackingActive else { return }
        locationManager.allowsBackgroundLocationUpdates = false
        isBackgroundTrackingActive = false
        logLocationChange(message: "Background location tracking stopped")
    }

    private func logLocationChange(message: String) {
        print(message)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            logLocationChange(message: "Location access denied or restricted")
        case .notDetermined:
            logLocationChange(message: "Location status not determined")
        @unknown default:
            logLocationChange(message: "Unknown location authorization status")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        lastLocation = location
        logLocationChange(message: "Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        logLocationToFirebaseIfNeeded(location: location)
        updateNearestMapPoint(for: location)

        if isAdventureModeEnabled {
            if isWithinSafeZone(coordinate: location.coordinate) {
                if !isBackgroundTrackingActive {
                    startBackgroundTracking()
                }
                checkVisitedLandmarks()
            } else if isBackgroundTrackingActive {
                stopBackgroundTracking()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == "SafeZone" && isAdventureModeEnabled {
            startBackgroundTracking()
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == "SafeZone" {
            stopBackgroundTracking()
        }
    }

    private func setupGeofenceForSafeZone() {
        let regionCenter = CLLocationCoordinate2D(
            latitude: (safeZoneCorners.bottomLeft.latitude + safeZoneCorners.topRight.latitude) / 2,
            longitude: (safeZoneCorners.bottomLeft.longitude + safeZoneCorners.topRight.longitude) / 2
        )
        let latDelta = safeZoneCorners.topRight.latitude - safeZoneCorners.bottomLeft.latitude
        let lonDelta = safeZoneCorners.topRight.longitude - safeZoneCorners.bottomLeft.longitude
        let radius = max(latDelta, lonDelta) * 111000 / 2 // Convert to meters (approx)

        let region = CLCircularRegion(center: regionCenter, radius: radius, identifier: "SafeZone")
        region.notifyOnEntry = true
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
    }

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

    private func updateNearestMapPoint(for location: CLLocation) {
        nearestMapPoint = findNearestMapPoint(to: location.coordinate)
    }
    
    
    // MARK: Landmark Functions
    // Checks proximity to landmarks and marks the nearest one visited.
    private func checkVisitedLandmarks() {
        guard let userLocation = lastLocation else { return }
        
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
            
            if nearestPoint.landmark != -1 && !nearestPoint.isVisited {
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

    // Mark a structure visited (map point)
    private func markPointAsVisitedByIndex(_ index: Int) {
        let mapPoints = mapPointManager.mapPoints
        if index >= 0 && index < mapPoints.count {
            let newIndex = index - 1;
            mapPoints[newIndex].isVisited = true
            markStructureAsVisited(mapPoints[newIndex].landmark)
        }
    }
    
    // Marks a landmark as visited in the system notifications.
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
    
    // Checks if a coordinate is within the predefined safe zone.
    public func isWithinSafeZone(coordinate: CLLocationCoordinate2D) -> Bool {
        let minLat = safeZoneCorners.bottomLeft.latitude
        let maxLat = safeZoneCorners.topRight.latitude
        let minLon = safeZoneCorners.bottomLeft.longitude
        let maxLon = safeZoneCorners.topRight.longitude
        
        return coordinate.latitude >= minLat && coordinate.latitude <= maxLat &&
               coordinate.longitude >= minLon && coordinate.longitude <= maxLon
    }
    

}

extension Notification.Name {
    static let allStructuresVisited = Notification.Name("allStructuresVisited")
}

