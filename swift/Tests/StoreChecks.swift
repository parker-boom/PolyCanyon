import Foundation
import CoreLocation

// Test-only stand-ins for UI routing and location hardware; production store code is compiled unchanged.
enum FullScreenView { case structInfo, settings, ghostStructInfo }
final class LocationService {
    static let shared = LocationService()
    func reset() { }
}
extension Notification.Name {
    static let structureVisited = Notification.Name("structureVisited")
}

@main
struct StoreChecks {
    @MainActor
    static func main() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let resourcePath = root.appendingPathComponent("Catalog.bundle/Contents/Resources")
        try FileManager.default.createDirectory(at: resourcePath, withIntermediateDirectories: true)
        let source = URL(fileURLWithPath: CommandLine.arguments[1])
        for filename in ["structuresList.json", "ghostStructures.json"] {
            try FileManager.default.copyItem(at: source.appendingPathComponent(filename), to: resourcePath.appendingPathComponent(filename))
        }
        let info: [String: String] = ["CFBundleIdentifier": "local.polycanyon.tests", "CFBundlePackageType": "BNDL"]
        let plist = try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
        try plist.write(to: root.appendingPathComponent("Catalog.bundle/Contents/Info.plist"))
        let bundle = Bundle(url: root.appendingPathComponent("Catalog.bundle"))!
        let suite = "PolyCanyonTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let directory = root.appendingPathComponent("Documents")
        var date = Date(timeIntervalSince1970: 1_750_000_000)
        let store = DataStore(directory: directory, defaults: defaults, bundle: bundle, now: { date })
        precondition(store.structures.count == 31 && store.ghostStructures.count == 6)
        store.toggleLike(for: 1)
        store.markStructureAsVisited(1)
        store.markStructureAsVisited(1)
        store.markGhostStructureAsVisited(101)
        precondition(store.totalVisitedCount == 2 && store.dayCount == 1)
        date = date.addingTimeInterval(86400)
        store.markStructureAsVisited(2)
        precondition(store.totalVisitedCount == 3 && store.dayCount == 2)
        defaults.set("old-catalog", forKey: "dataVersion")
        let restored = DataStore(directory: directory, defaults: defaults, bundle: bundle)
        precondition(restored.isLiked(for: 1) && restored.structures[0].isVisited)
        precondition(restored.ghostStructures[0].isVisited && restored.totalVisitedCount == 3)
        restored.resetLikes()
        precondition(!restored.isLiked(for: 1) && restored.totalVisitedCount == 3)
        precondition(restored.getFilteredStructures(searchText: "zzzz-no-match", sortState: .all).isEmpty)
        precondition(restored.getFilteredStructures(searchText: "Ghost", sortState: .all).last?.number == 999)
        precondition(restored.getRecentlyVisitedStructures(limit: -1).isEmpty)
        restored.resetStructures()
        precondition(restored.totalVisitedCount == 0 && restored.dayCount == 0)
        precondition(!restored.ghostStructures.contains { $0.isVisited })
        precondition(restored.lastVisitedStructure == nil && restored.lastVisitedGhostStructure == nil)
        let state = AppState(defaults: defaults)
        defaults.set("keep", forKey: "unrelatedSetting")
        state.isVirtualWalkthrough = true
        state.currentStructureIndex = 20
        state.activeFullScreenView = .structInfo
        state.resetAllSettings()
        precondition(!state.isVirtualWalkthrough && state.currentStructureIndex == 0 && state.activeFullScreenView == nil)
        precondition(defaults.string(forKey: "unrelatedSetting") == "keep")
        defaults.set(Double.infinity, forKey: "mapScale")
        precondition(AppState(defaults: defaults).mapScale == 1)
        defaults.set(-3, forKey: "mapScale")
        precondition(AppState(defaults: defaults).mapScale == 1)
        let coordinate = CLLocationCoordinate2D(latitude: 35.31583, longitude: -120.65347)
        func fix(accuracy: Double, age: Double) -> CLLocation {
            CLLocation(coordinate: coordinate, altitude: 0, horizontalAccuracy: accuracy,
                       verticalAccuracy: -1, timestamp: date.addingTimeInterval(-age))
        }
        precondition(LocationSamplePolicy.canAwardVisit(fix(accuracy: 5, age: 0), now: date))
        precondition(!LocationSamplePolicy.isUsable(fix(accuracy: -1, age: 0), now: date))
        precondition(!LocationSamplePolicy.isUsable(fix(accuracy: 5, age: 60), now: date))
        precondition(!LocationSamplePolicy.canAwardVisit(fix(accuracy: 500, age: 0), now: date))
        // Force a write failure after a valid save by putting a directory at the destination.
        let savedProgress = directory.appendingPathComponent("progress.json")
        let savedBytes = try Data(contentsOf: savedProgress)
        try FileManager.default.removeItem(at: savedProgress)
        try FileManager.default.createDirectory(at: savedProgress, withIntermediateDirectories: false)
        restored.toggleLike(for: 1)
        restored.markStructureAsVisited(1)
        precondition(!restored.isLiked(for: 1) && restored.totalVisitedCount == 0)
        precondition(restored.lastVisitedStructure == nil && restored.persistenceError != nil)
        try FileManager.default.removeItem(at: savedProgress)
        try savedBytes.write(to: savedProgress)
        restored.resumeAutomaticVisits()
        restored.markGhostStructureAsVisited(101)
        precondition(restored.totalVisitedCount == 1)
        // Failure of a full reset must not clear either catalog, counters or notifications.
        let beforeReset = try Data(contentsOf: savedProgress)
        try FileManager.default.removeItem(at: savedProgress)
        try FileManager.default.createDirectory(at: savedProgress, withIntermediateDirectories: false)
        restored.resetStructures()
        precondition(restored.ghostStructures[0].isVisited && restored.totalVisitedCount == 1)
        precondition(restored.lastVisitedGhostStructure != nil)
        try FileManager.default.removeItem(at: savedProgress)
        try beforeReset.write(to: savedProgress)
        let afterFailure = DataStore(directory: directory, defaults: defaults, bundle: bundle)
        precondition(afterFailure.ghostStructures[0].isVisited && afterFailure.totalVisitedCount == 1)

        // Legacy migration is read-only until an edit, and preserves both catalogs and days.
        let legacyDirectory = root.appendingPathComponent("Legacy")
        let legacyDisk = CatalogPersistence(directory: legacyDirectory)
        try FileManager.default.createDirectory(at: legacyDirectory, withIntermediateDirectories: true)
        let fixtures = URL(fileURLWithPath: CommandLine.arguments[2])
        for name in ["structures.json", "ghostStructures.json"] {
            try FileManager.default.copyItem(at: fixtures.appendingPathComponent(name), to: legacyDirectory.appendingPathComponent(name))
        }
        defaults.set(7, forKey: "dayCount")
        let migration = DataStore(directory: legacyDirectory, defaults: defaults, bundle: bundle)
        precondition(migration.dayCount == 7 && migration.ghostStructures[0].isVisited)
        precondition(migration.isLiked(for: 1) && migration.structures[0].isOpened && migration.totalVisitedCount == 2)
        precondition(!FileManager.default.fileExists(atPath: legacyDirectory.appendingPathComponent("progress.json").path))
        migration.toggleLike(for: 2)
        let migrated = DataStore(directory: legacyDirectory, defaults: defaults, bundle: bundle)
        precondition(migrated.isLiked(for: 1) && migrated.isLiked(for: 2) && migrated.dayCount == 7 && migrated.ghostStructures[0].isVisited)
        // Unknown future schema must never be overwritten by an older app.
        var future = try legacyDisk.load(CatalogSnapshot.self, from: "progress.json")!
        future.schemaVersion = 99
        try legacyDisk.save(future, to: "progress.json")
        let unsupported = DataStore(directory: legacyDirectory, defaults: defaults, bundle: bundle)
        unsupported.resetStructures()
        let unchanged = try JSONSerialization.jsonObject(with: Data(contentsOf: legacyDirectory.appendingPathComponent("progress.json"))) as! [String: Any]
        precondition(unchanged["schemaVersion"] as? Int == 99)
        precondition(unsupported.persistenceError?.contains("newer version") == true)
        print("PASS: atomic reset, failed-write rollback, legacy migration, future-schema protection")
        print("PASS: fresh and returning stores, visits, day counts, favorites reset, search, full reset, invalid location fixes")
    }
}
