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



class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var mapPointManager: MapPointManager
    private var structureData: StructureData
    private var lastLoggedMapPoint: MapPoint?
    
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var nearestMapPoint: MapPoint?
    @Published var isMonitoringSignificantLocationChanges = false
    @Published var isInSafeZone = false

    // Define safe long and lat zone
    private let safeZoneCorners = (
        bottomLeft: CLLocationCoordinate2D(latitude: 35.31214, longitude: -120.65529),
        topRight: CLLocationCoordinate2D(latitude: 35.31813, longitude: -120.65110)
    )
    
    // Declare Firebase database reference
    private var firestoreRef: Firestore!
    private var userID: String

    @Published var isAdventureModeEnabled: Bool {
        didSet {
            updateLocationTracking()
        }
    }

    init(mapPointManager: MapPointManager, structureData: StructureData, isAdventureModeEnabled: Bool) {
        self.userID = UserDefaults.standard.string(forKey: "userID") ?? UUID().uuidString
        UserDefaults.standard.set(self.userID, forKey: "userID")
        
        self.mapPointManager = mapPointManager
        self.structureData = structureData
        self.isAdventureModeEnabled = isAdventureModeEnabled
        
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
            startInAppTracking()
        } else {
            stopAllTracking()
        }
    }

    private func startInAppTracking() {
        locationManager.startUpdatingLocation()
        print("In-app location tracking started")
    }

    private func startBackgroundTracking() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        print("Background location tracking started")
    }

    private func stopAllTracking() {
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        print("All location tracking stopped")
    }

    private func stopBackgroundTracking() {
        locationManager.allowsBackgroundLocationUpdates = false
        print("Background location tracking stopped")
    }
    
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            print("Location access denied or restricted")
        case .notDetermined:
            print("Location status not determined")
        @unknown default:
            print("Unknown location authorization status")
        }
    }

    
    // Setup location manager
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if #available(iOS 14.0, *) {
            // For iOS 14 and later, the new method will be called instead
            return
        }
        locationStatus = status
        handleAuthorization(status: status)
        setupGeofenceForSafeZone()
    }

    private func logLocationToFirebaseIfNeeded(location: CLLocation) {
        guard let newMapPoint = findNearestMapPoint(to: location.coordinate),
              newMapPoint != lastLoggedMapPoint else { return }

        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": Timestamp(date: Date()),
            "userId": userID
        ]
        firestoreRef.collection("user_locations").addDocument(data: locationData) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
        lastLoggedMapPoint = newMapPoint
    }

    
    // Function to ensure that Firebase only gets pinged on mapPoint change
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


    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        logLocationToFirebaseIfNeeded(location: location)
        updateNearestMapPoint(for: location)

        if isAdventureModeEnabled {
            if isWithinSafeZone(coordinate: location.coordinate) {
                if !isInSafeZone {
                    isInSafeZone = true
                    startBackgroundTracking()
                }
                checkVisitedLandmarks()
            } else {
                if isInSafeZone {
                    isInSafeZone = false
                    stopBackgroundTracking()
                }
            }
        }
    }
    
    
    private func updateNearestMapPoint(for location: CLLocation) {
        nearestMapPoint = findNearestMapPoint(to: location.coordinate)
    }

    

    // Setup geo fence so user location isn't constantly tracked outside of Poly Canyon
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


    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == "SafeZone" && isAdventureModeEnabled {
            isInSafeZone = true
            startBackgroundTracking()
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == "SafeZone" {
            isInSafeZone = false
            stopBackgroundTracking()
        }
    }

    // Handle different cases of authorization
    private func handleAuthorization(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            if let lastLocation = lastLocation, isWithinSafeZone(coordinate: lastLocation.coordinate) {
                startUpdatingLocation()
            }
        case .restricted, .denied:
            break
        @unknown default:
            break
        }
    }

    // Starts high-frequency location updates.
    func startUpdatingLocation() {
        //if CLLocationManager.locationServicesEnabled() {
            if let lastLocation = lastLocation, isWithinSafeZone(coordinate: lastLocation.coordinate) {
                locationManager.startMonitoringSignificantLocationChanges()
            }
        //}
    }

    
    private func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }

    private func startBackgroundLocationUpdates() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }

    private func stopBackgroundLocationUpdates() {
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
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
        
        if let nearestPoint = nearestMapPoint, nearestPoint.landmark != -1 && !nearestPoint.isVisited {
            nearestPoint.isVisited = true
            mapPointManager.saveVisitedStatus()
            markStructureAsVisited(nearestPoint.landmark)
            
            // Check based on the landmark number and mark additional points as visited
            switch nearestPoint.landmark {
            case 8:
                markPointAsVisitedByIndex(54)
                markPointAsVisitedByIndex(196)
            case 13:
                markPointAsVisitedByIndex(19)
                markPointAsVisitedByIndex(108)
            case 14:
                markPointAsVisitedByIndex(59)
                markPointAsVisitedByIndex(80)
            case 15:
                markPointAsVisitedByIndex(21)
                markPointAsVisitedByIndex(130)
            case 17:
                markPointAsVisitedByIndex(24)
                markPointAsVisitedByIndex(132)
            case 20:
                markPointAsVisitedByIndex(26)
                markPointAsVisitedByIndex(91)
            case 22:
                markPointAsVisitedByIndex(36)
                markPointAsVisitedByIndex(113)
            case 30:
                markPointAsVisitedByIndex(49)
                markPointAsVisitedByIndex(60)
            case 31:
                markPointAsVisitedByIndex(68)
                markPointAsVisitedByIndex(161)
            case 32:
                markPointAsVisitedByIndex(23)
                markPointAsVisitedByIndex(50)
            default:
                break
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

