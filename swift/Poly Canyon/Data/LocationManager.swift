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
    @Published var isMonitoringSignificantLocationChanges = false

    // Define safe long and lat zone
    private let safeZoneCorners = (
        bottomLeft: CLLocationCoordinate2D(latitude: 35.31214, longitude: -120.65529),
        topRight: CLLocationCoordinate2D(latitude: 35.31813, longitude: -120.65110)
    )
    
    // Declare Firebase database reference
    private var firestoreRef: Firestore!
    private var userID: String

    // Initializes the location manager and configures its settings.
    init(mapPointManager: MapPointManager, structureData: StructureData) {
        self.userID = UserDefaults.standard.string(forKey: "userID") ?? UUID().uuidString
        UserDefaults.standard.set(self.userID, forKey: "userID")

        self.mapPointManager = MapPointManager()
        self.structureData = StructureData()

        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        requestAlwaysAuthorizationIfNeeded()  
        
        // Initialize Firebase database reference
        firestoreRef = Firestore.firestore()
    }


    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            // Prompt for "Always" authorization
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted, .notDetermined:
            print("Location authorization denied or not determined.")
        @unknown default:
            fatalError("Unhandled authorization status")
        }
    }

    
    
    func requestAlwaysAuthorizationIfNeeded() {
        if locationManager.authorizationStatus != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
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


    
    // Updates the location when new location data is available.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        logLocationToFirebaseIfNeeded(location: location)

        if isWithinSafeZone(coordinate: location.coordinate) {
            lastLocation = location
            checkVisitedLandmarks()
            startUpdatingLocation()
            isMonitoringSignificantLocationChanges = false
        } else {
            locationManager.startMonitoringSignificantLocationChanges()
            isMonitoringSignificantLocationChanges = true
        }
    }


    // Setup geo fence so user location isn't constantly tracked outside of Poly Canyon
    private func setupGeofenceForSafeZone() {
        let regionCenter = CLLocationCoordinate2D(latitude: (safeZoneCorners.bottomLeft.latitude + safeZoneCorners.topRight.latitude) / 2,
                                                  longitude: (safeZoneCorners.bottomLeft.longitude + safeZoneCorners.topRight.longitude) / 2)
        let region = CLCircularRegion(center: regionCenter, radius: 1500, identifier: "SafeZone")
        region.notifyOnEntry = true
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
    }

    // Declare safe zone
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == "SafeZone" {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == "SafeZone" {
            locationManager.stopUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
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

    // Stops all location updates.
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
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
            var newIndex = index - 1;
            mapPoints[newIndex].isVisited = true
            markStructureAsVisited(mapPoints[newIndex].landmark)
        }
    }
    
    // Marks a landmark as visited in the system notifications.
    private func markStructureAsVisited(_ landmarkId: Int) {
        NotificationCenter.default.post(name: .structureVisited, object: landmarkId)
    }
    
    // Checks if a coordinate is within the predefined safe zone.
    private func isWithinSafeZone(coordinate: CLLocationCoordinate2D) -> Bool {
        let minLat = safeZoneCorners.bottomLeft.latitude
        let maxLat = safeZoneCorners.topRight.latitude
        let minLon = safeZoneCorners.bottomLeft.longitude
        let maxLon = safeZoneCorners.topRight.longitude
        
        return coordinate.latitude >= minLat && coordinate.latitude <= maxLat &&
               coordinate.longitude >= minLon && coordinate.longitude <= maxLon
    }
    

}

extension LocationManager {
    // Requests "Always" authorization for location services.
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
}

extension Notification.Name {
    static let allStructuresVisited = Notification.Name("allStructuresVisited")
}

