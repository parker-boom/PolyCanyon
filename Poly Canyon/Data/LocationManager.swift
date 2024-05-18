// MARK: LocationManager.swift
// This file defines the LocationManager class for handling location functionalities in the Cal Poly architecture graveyard app. It utilizes CoreLocation for managing location services and tracking user movement within a predefined safe zone.

// Notable features include:
// - Adaptive location update frequencies based on user proximity to the safe zone.
// - Geofencing to notify entry and exit from this area.
// - Tracking and updating visited landmarks based on the user's location.

// The class efficiently handles location permissions and updates, crucial for guiding users through the architectural structures in the area.





// MARK: Code
import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var mapPointManager: MapPointManager
    private var structureData: StructureData
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var isMonitoringSignificantLocationChanges = false
    
    private let safeZoneCorners = (
        bottomLeft: CLLocationCoordinate2D(latitude: 35.31214, longitude: -120.65529),
        topRight: CLLocationCoordinate2D(latitude: 35.31813, longitude: -120.65110)
    )

    // Initializes the location manager and configures its settings.
    init(mapPointManager: MapPointManager, structureData: StructureData) {
        self.mapPointManager = mapPointManager
        self.structureData = structureData
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted, .notDetermined:
            print("Location authorization denied or not determined.")
        @unknown default:
            fatalError("Unhandled authorization status")
        }
    }



    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if #available(iOS 14.0, *) {
            // For iOS 14 and later, the new method will be called instead
            return
        }
        locationStatus = status
        handleAuthorization(status: status)
        setupGeofenceForSafeZone()
    }

    // Updates the location when new location data is available.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        
        if isWithinSafeZone(coordinate: location.coordinate) {
            lastLocation = location
            checkVisitedLandmarks()
            startUpdatingLocation()  // Ensure it's using high-frequency updates within the zone
            isMonitoringSignificantLocationChanges = false
        } else {
            locationManager.startMonitoringSignificantLocationChanges()  // Lower frequency updates
            isMonitoringSignificantLocationChanges = true
        }
    }
    
    private func setupGeofenceForSafeZone() {
        let regionCenter = CLLocationCoordinate2D(latitude: (safeZoneCorners.bottomLeft.latitude + safeZoneCorners.topRight.latitude) / 2,
                                                  longitude: (safeZoneCorners.bottomLeft.longitude + safeZoneCorners.topRight.longitude) / 2)
        let region = CLCircularRegion(center: regionCenter, radius: 1500, identifier: "SafeZone")
        region.notifyOnEntry = true
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
    }

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
            case 13:
                markPointAsVisitedByIndex(19)
                markPointAsVisitedByIndex(108)
            case 14:
                markPointAsVisitedByIndex(58)
                markPointAsVisitedByIndex(79)
            case 19:
                markPointAsVisitedByIndex(87)
            case 22:
                markPointAsVisitedByIndex(35)
                markPointAsVisitedByIndex(112)
            case 30:
                markPointAsVisitedByIndex(49)
                markPointAsVisitedByIndex(60)
            default:
                break
            }
        }
    }

    private func markPointAsVisitedByIndex(_ index: Int) {
        let mapPoints = mapPointManager.mapPoints
        if index >= 0 && index < mapPoints.count {
            mapPoints[index].isVisited = true
            markStructureAsVisited(mapPoints[index].landmark)
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

