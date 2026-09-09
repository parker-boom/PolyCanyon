import Foundation

@main
struct ModelChecks {
    static func main() throws {
        let dataDirectory = URL(fileURLWithPath: CommandLine.arguments[1])
        let decoder = JSONDecoder()
        let structures = try decoder.decode([Structure].self, from: Data(contentsOf: dataDirectory.appendingPathComponent("structuresList.json")))
        let ghosts = try decoder.decode([GhostStructure].self, from: Data(contentsOf: dataDirectory.appendingPathComponent("ghostStructures.json")))
        let points = try decoder.decode([MapPointData].self, from: Data(contentsOf: dataDirectory.appendingPathComponent("mapPoints.json")))
        precondition(structures.count == 31 && ghosts.count == 6 && points.count == 231)
        precondition(structures.first { $0.number == 24 }?.catalogDates == "1964 / 1975")
        precondition(structures.first { $0.number == 8 }?.catalogDates == "1990 / 2024")
        for year in ["", "xxxx", "  XXXX  "] {
            var record = try JSONSerialization.jsonObject(with: JSONEncoder().encode(structures[0])) as! [String: Any]
            record["Year"] = year
            let unknown = try decoder.decode(Structure.self, from: JSONSerialization.data(withJSONObject: record))
            precondition(unknown.catalogDates == nil)
        }
        precondition(structures.allSatisfy { !$0.images.isEmpty })
        precondition(ghosts.allSatisfy { !$0.images.isEmpty && !$0.isVisited })
        var visitedGhost = ghosts[0]
        visitedGhost.markAsVisited()
        let restored = try decoder.decode(GhostStructure.self, from: JSONEncoder().encode(visitedGhost))
        precondition(restored.isVisited, "Ghost visits must survive saving and relaunching")
        precondition(restored.number == visitedGhost.number)
        var favorite = structures[0]
        favorite.isLiked = true
        favorite.isVisited = true
        favorite.isOpened = true
        favorite.recentlyVisited = 12345
        let merged = CatalogProgress.merge(structures, saved: [favorite, favorite])
        precondition(merged.count == 31 && merged[0].isLiked && merged[0].isVisited)
        precondition(merged[0].recentlyVisited == 12345 && merged[0].isOpened)
        precondition(merged[1] == structures[1])
        precondition(favorite != structures[0], "Equality must include progress changes")
        let ghostMerge = CatalogProgress.merge(ghosts, saved: [visitedGhost])
        precondition(ghostMerge[0].isVisited && !ghostMerge[1].isVisited)
        let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: temporary) }
        let persistence = CatalogPersistence(directory: temporary)
        let missing = try persistence.load([Structure].self, from: "missing.json")
        precondition(missing == nil)
        try persistence.save(merged, to: "structures.json")
        let roundTrip = try persistence.load([Structure].self, from: "structures.json")
        precondition(roundTrip == merged)
        let corrupt = temporary.appendingPathComponent("corrupt.json")
        try Data("broken".utf8).write(to: corrupt)
        do {
            _ = try persistence.load([Structure].self, from: "corrupt.json")
            preconditionFailure("Corrupt JSON must report failure")
        } catch { }
        let original = try Data(contentsOf: corrupt)
        precondition(original == Data("broken".utf8))
        let backups = try FileManager.default.contentsOfDirectory(atPath: temporary.path)
        precondition(backups.contains { $0.hasPrefix("corrupt.json.unreadable") })
        _ = try? persistence.load([Structure].self, from: "corrupt.json")
        let repeatedBackups = try FileManager.default.contentsOfDirectory(atPath: temporary.path)
        precondition(repeatedBackups.filter { $0.hasPrefix("corrupt.json.unreadable") }.count == 1)
        print("PASS: catalog merge, duplicate IDs, equality, missing files, atomic round trip, corrupt-file preservation")
        print("PASS: bundled data decodes and ghost visits survive a persistence round trip")
    }
}
