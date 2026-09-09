import CoreLocation
import Foundation

/// Cached or invalid fixes must not reveal structures or award visits.
enum LocationSamplePolicy {
    static func isUsable(_ location: CLLocation, now: Date = Date()) -> Bool {
        let age = now.timeIntervalSince(location.timestamp)
        return CLLocationCoordinate2DIsValid(location.coordinate)
            && location.horizontalAccuracy >= 0
            && age >= -5 && age <= 30
    }

    static func canAwardVisit(_ location: CLLocation, now: Date = Date()) -> Bool {
        isUsable(location, now: now) && location.horizontalAccuracy <= 50
    }
}
