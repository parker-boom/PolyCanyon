//
//  OnboardingLocationManager.swift
//  Poly Canyon
//
//  Created by Parker Jones on 8/29/24.
//

import Foundation
import CoreLocation

class OnboardingLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var isNearCalPoly: Bool = false
    @Published var hasRequestedLocation = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        hasRequestedLocation = true
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        checkIfNearCalPoly(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
    }

    private func checkIfNearCalPoly(location: CLLocation) {
        let calPolyLocation = CLLocation(latitude: 35.3050, longitude: -120.6625)
        let distanceInMeters = location.distance(from: calPolyLocation)
        isNearCalPoly = distanceInMeters <= 80467 // 50 miles in meters
    }
}
