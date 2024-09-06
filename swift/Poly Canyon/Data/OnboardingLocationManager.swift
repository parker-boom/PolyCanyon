//
//  OnboardingLocationManager.swift
//  Poly Canyon
//
//  Created by Parker Jones on 8/29/24.
//
import SwiftUI
import CoreLocation

class OnboardingLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var isNearCalPoly: Bool = false
    @Published var hasRequestedPermission = false
    @Published var isLocationDetermined = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        print("DEBUG: OnboardingLocationManager initialized")
    }

    func requestPermission() {
        print("DEBUG: Requesting location permission")
        locationManager.requestWhenInUseAuthorization()
        hasRequestedPermission = true
    }

    func fetchLocation() {
        print("DEBUG: Fetching location")
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("DEBUG: Location updated - \(location.coordinate.latitude), \(location.coordinate.longitude)")
        lastLocation = location
        checkIfNearCalPoly(location: location)
        isLocationDetermined = true
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DEBUG: Location manager error - \(error.localizedDescription)")
        isLocationDetermined = true
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
        print("DEBUG: Location authorization status changed - \(locationStatus?.rawValue ?? -1)")
    }

    private func checkIfNearCalPoly(location: CLLocation) {
        let calPolyLocation = CLLocation(latitude: 35.3050, longitude: -120.6625)
        let distanceInMeters = location.distance(from: calPolyLocation)
        isNearCalPoly = distanceInMeters <= 80467 // 50 miles in meters
        print("DEBUG: Is near Cal Poly? \(isNearCalPoly) (Distance: \(distanceInMeters) meters)")
    }
}

