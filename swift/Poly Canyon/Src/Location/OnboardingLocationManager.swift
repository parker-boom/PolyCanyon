// MARK: OnboardingLocationManager.swift

import SwiftUI
import CoreLocation

/**
 * OnboardingLocationManager
 *
 * Handles location services during the onboarding phase of the Poly Canyon app.
 * It manages location permissions, fetches the user's current location, and determines
 * if the user is near the Cal Poly campus. This ensures that users provide necessary
 * location data to enhance their app experience.
 */
class OnboardingLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var isNearCalPoly: Bool = false
    @Published var hasRequestedPermission = false
    @Published var isLocationDetermined = false

    /**
     * Initializes the OnboardingLocationManager and sets up the CLLocationManager delegate and accuracy.
     */
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        print("DEBUG: OnboardingLocationManager initialized")
    }

    /**
     * Requests when-in-use location permission from the user.
     */
    func requestPermission() {
        print("DEBUG: Requesting location permission")
        locationManager.requestWhenInUseAuthorization()
        hasRequestedPermission = true
    }

    /**
     * Initiates a one-time request to fetch the user's current location.
     */
    func fetchLocation() {
        print("DEBUG: Fetching location")
        locationManager.requestLocation()
    }

    // MARK: CLLocationManagerDelegate Methods

    /**
     * Handles successful location updates by storing the location and checking proximity to Cal Poly.
     *
     * - Parameters:
     *   - manager: The CLLocationManager instance.
     *   - locations: An array of CLLocation objects representing updated locations.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("DEBUG: Location updated - \(location.coordinate.latitude), \(location.coordinate.longitude)")
        lastLocation = location
        checkIfNearCalPoly(location: location)
        isLocationDetermined = true
    }

    /**
     * Handles location manager errors by logging the error and marking location determination as complete.
     *
     * - Parameters:
     *   - manager: The CLLocationManager instance.
     *   - error: The error encountered during location updates.
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DEBUG: Location manager error - \(error.localizedDescription)")
        isLocationDetermined = true
    }

    /**
     * Handles changes in location authorization status by updating the published status.
     *
     * - Parameter manager: The CLLocationManager instance.
     */
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
        print("DEBUG: Location authorization status changed - \(locationStatus?.rawValue ?? -1)")
    }

    /**
     * Checks if the user's current location is within 50 miles of the Cal Poly campus.
     *
     * - Parameter location: The CLLocation object representing the user's current location.
     */
    private func checkIfNearCalPoly(location: CLLocation) {
        let calPolyLocation = CLLocation(latitude: 35.3050, longitude: -120.6625)
        let distanceInMeters = location.distance(from: calPolyLocation)
        isNearCalPoly = distanceInMeters <= 80467 // 50 miles in meters
        print("DEBUG: Is near Cal Poly? \(isNearCalPoly) (Distance: \(distanceInMeters) meters)")
    }
}
