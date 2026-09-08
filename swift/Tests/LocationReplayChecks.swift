import Foundation
import CoreLocation

/// Hardware is the only replacement. Decisions, geometry, throttling, notifications and saves are production code.
@MainActor
final class ReplayLocationManager: LocationManaging {
    weak var delegate: CLLocationManagerDelegate?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var desiredAccuracy: CLLocationAccuracy = 0
    var distanceFilter: CLLocationDistance = 0
    var pausesLocationUpdatesAutomatically = true
    var running = false
    var starts = 0
    var stops = 0
    var requests = 0
    func requestWhenInUseAuthorization() { requests += 1 }
    func startUpdatingLocation() { running = true; starts += 1 }
    func stopUpdatingLocation() { running = false; stops += 1 }
}

@main
struct LocationReplayChecks {
    @MainActor
    static func main() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let resources = root.appendingPathComponent("Replay.bundle/Contents/Resources")
        try FileManager.default.createDirectory(at: resources, withIntermediateDirectories: true)
        let source = URL(fileURLWithPath: CommandLine.arguments[1])
        for name in ["structuresList.json", "ghostStructures.json", "mapPoints.json"] {
            try FileManager.default.copyItem(at: source.appendingPathComponent(name), to: resources.appendingPathComponent(name))
        }
        try PropertyListSerialization.data(fromPropertyList: ["CFBundleIdentifier": "local.polycanyon.replay", "CFBundlePackageType": "BNDL"], format: .xml, options: 0)
            .write(to: root.appendingPathComponent("Replay.bundle/Contents/Info.plist"))
        let bundle = Bundle(url: root.appendingPathComponent("Replay.bundle"))!
        let suite = "PolyCanyonReplay.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let notifications = NotificationCenter()
        let manager = ReplayLocationManager()
        var time = Date(timeIntervalSince1970: 1_750_000_000)
        let service = LocationService(manager: manager, bundle: bundle, defaults: defaults,
                                      notifications: notifications, now: { time })
        let directory = root.appendingPathComponent("Documents")
        let store = DataStore(directory: directory, defaults: defaults, bundle: bundle,
                              notifications: notifications, now: { time })
        func sample(_ coordinate: CLLocationCoordinate2D, accuracy: Double = 5, age: Double = 0) -> CLLocation {
            CLLocation(coordinate: coordinate, altitude: 0, horizontalAccuracy: accuracy,
                       verticalAccuracy: -1, timestamp: time.addingTimeInterval(-age))
        }
        func point(_ number: Int) -> CLLocationCoordinate2D {
            service.mapPoints.first { $0.structure == number }!.coordinate
        }
        func send(_ number: Int, accuracy: Double = 5, age: Double = 0, advance: Double = 2) {
            time.addTimeInterval(advance)
            service.receiveLocations([sample(point(number), accuracy: accuracy, age: age)])
        }
        func authorize(_ status: CLAuthorizationStatus) {
            manager.authorizationStatus = status
            service.refreshAuthorization()
        }
        precondition(service.mapPoints.count == 231)
        for structure in store.structures {
            precondition(service.getMapPointForStructure(structure.number)?.structure == structure.number)
        }
        // No permission, pending onboarding and a permission grant never award a visit by themselves.
        service.configure()
        service.setAppActive(true)
        send(1)
        precondition(!manager.running && store.totalVisitedCount == 0)
        service.requestInitialPermission()
        precondition(manager.requests == 1 && !manager.running)
        authorize(.authorizedWhenInUse)
        send(1)
        precondition(manager.running && store.totalVisitedCount == 0)
        service.setAppActive(false)
        precondition(!manager.running && service.trackingState == .inactive)
        service.setAppActive(true)
        service.setMode(.adventure)
        send(1)
        precondition(store.totalVisitedCount == 1 && store.structures[0].isVisited)
        send(1)
        precondition(store.totalVisitedCount == 1 && store.dayCount == 1)
        // Real coordinate sequences, invalid cached fixes, and receipt-time throttling.
        send(2, age: 31)
        send(2, accuracy: -1)
        send(2, accuracy: 500)
        send(2, age: -6)
        time.addTimeInterval(2)
        service.receiveLocations([sample(CLLocationCoordinate2D(latitude: 91, longitude: 0))])
        service.receiveLocations([])
        precondition(store.totalVisitedCount == 1)
        send(2)
        send(3, advance: 0.2)
        precondition(store.totalVisitedCount == 2)
        send(3)
        precondition(store.totalVisitedCount == 3)
        authorize(.denied)
        send(4)
        precondition(!manager.running && service.lastLocation == nil && service.nearbyStructures.isEmpty)
        authorize(.restricted)
        send(4)
        precondition(store.totalVisitedCount == 3)
        authorize(.authorizedAlways)
        send(4)
        precondition(store.totalVisitedCount == 4)
        // Switching to virtual rejects already-queued GPS callbacks and clears the visible dot.
        service.setMode(.virtualTour)
        send(5)
        precondition(!manager.running && service.lastLocation == nil && store.totalVisitedCount == 4)
        service.setMode(.adventure)
        send(101)
        precondition(manager.running && service.trackingState == .inAppOnly)
        // Both inactive and background scenes stop GPS, even nearby with an existing Always grant.
        let startsBeforePause = manager.starts
        service.setAppActive(false)
        precondition(!manager.running && service.lastLocation == nil)
        send(102)
        precondition(!store.ghostStructures.first { $0.number == "102" }!.isVisited)
        service.setAppActive(false)
        precondition(manager.starts == startsBeforePause)
        service.setAppActive(true)
        precondition(manager.running && manager.starts == startsBeforePause + 1)
        send(102)
        precondition(store.ghostStructures.first { $0.number == "102" }!.isVisited)
        service.setAppActive(false)
        // Permission changes while away are reconciled on return, not just through a delegate callback.
        manager.authorizationStatus = .denied
        service.setAppActive(true)
        send(103)
        precondition(!manager.running && !store.ghostStructures.first { $0.number == "103" }!.isVisited)
        service.setAppActive(false)
        manager.authorizationStatus = .authorizedAlways
        service.setAppActive(true)
        send(103)
        precondition(store.ghostStructures.first { $0.number == "103" }!.isVisited)
        service.setMode(.virtualTour)
        service.setAppActive(false)
        service.setAppActive(true)
        send(104)
        precondition(!manager.running && !store.ghostStructures.first { $0.number == "104" }!.isVisited)
        service.setMode(.adventure)
        service.setAppActive(false)
        time.addTimeInterval(31)
        service.setAppActive(true)
        precondition(service.lastLocation == nil && manager.running)
        // A failed GPS save preserves progress and does not repeat alerts on every callback.
        let savedURL = directory.appendingPathComponent("progress.json")
        let savedBytes = try Data(contentsOf: savedURL)
        try FileManager.default.removeItem(at: savedURL)
        try FileManager.default.createDirectory(at: savedURL, withIntermediateDirectories: false)
        send(104)
        precondition(store.persistenceError != nil && !store.ghostStructures.first { $0.number == "104" }!.isVisited)
        store.dismissPersistenceError()
        send(104)
        precondition(store.persistenceError == nil)
        try FileManager.default.removeItem(at: savedURL)
        try savedBytes.write(to: savedURL)
        send(104)
        precondition(!store.ghostStructures.first { $0.number == "104" }!.isVisited)
        store.resumeAutomaticVisits()
        send(104)
        precondition(store.ghostStructures.first { $0.number == "104" }!.isVisited)
        // Every tagged production point maps to its own label. Untagged trail points do not award visits.
        for mapPoint in service.mapPoints {
            precondition(service.findNearestMapPoint(to: mapPoint.coordinate)?.structure == mapPoint.structure)
        }
        let beforeTrail = store.totalVisitedCount
        for mapPoint in service.mapPoints where mapPoint.structure == -1 {
            time.addTimeInterval(2)
            service.receiveLocations([sample(mapPoint.coordinate)])
        }
        precondition(store.totalVisitedCount == beforeTrail)
        let tagged = Set(service.mapPoints.map(\.structure).filter { $0 > 0 })
        for number in tagged.sorted() { send(number) }
        precondition(store.structures.allSatisfy(\.isVisited))
        precondition(store.totalVisitedCount == 35)
        precondition(store.ghostStructures.filter(\.isVisited).map(\.number).sorted() == ["101", "102", "103", "104"])
        let restored = DataStore(directory: directory, defaults: defaults, bundle: bundle, notifications: NotificationCenter())
        precondition(restored.totalVisitedCount == 35 && restored.dayCount == 1)
        service.reset()
        precondition(!manager.running && service.currentMode == .initial && service.lastLocation == nil)
        print("PASS: production foreground-only replay: inactive/background stop, return, denied/Always permissions, virtual mode, stale fixes and throttling")
        print("PASS: all 231 map points, 35 discoverable structures, untagged trails, notification-to-save integration and relaunch")
        print("DATA LIMIT: ghost structures 105/106 have no tagged coordinates; no coordinates fabricated")
    }
}
