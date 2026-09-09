import Foundation

/// A single atomic commit keeps the two catalogs and visit-day statistics consistent.
struct CatalogSnapshot: Codable {
    var schemaVersion = 1
    var structures: [Structure]
    var ghosts: [GhostStructure]
    var dayCount: Int
    var previousDayVisited: String?
}

enum ProgressReadError: Error {
    case unsupportedVersion(Int)
}

extension CatalogSnapshot {
    private enum CodingKeys: String, CodingKey {
        case schemaVersion, structures, ghosts, dayCount, previousDayVisited
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.decode(Int.self, forKey: .schemaVersion)
        guard schemaVersion == 1 else { throw ProgressReadError.unsupportedVersion(schemaVersion) }
        structures = try values.decode([Structure].self, forKey: .structures)
        ghosts = try values.decode([GhostStructure].self, forKey: .ghosts)
        dayCount = try values.decode(Int.self, forKey: .dayCount)
        previousDayVisited = try values.decodeIfPresent(String.self, forKey: .previousDayVisited)
    }
}

/// Keeps bundled research authoritative while carrying forward only user progress.
enum CatalogProgress {
    static func merge(_ catalog: [Structure], saved: [Structure]) -> [Structure] {
        let progress = Dictionary(saved.map { ($0.number, $0) }, uniquingKeysWith: { _, last in last })
        return catalog.map { entry in
            guard let previous = progress[entry.number] else { return entry }
            var result = entry
            result.isVisited = previous.isVisited
            result.isOpened = previous.isOpened
            result.recentlyVisited = previous.recentlyVisited
            result.isLiked = previous.isLiked
            return result
        }
    }

    static func merge(_ catalog: [GhostStructure], saved: [GhostStructure]) -> [GhostStructure] {
        let progress = Dictionary(saved.map { ($0.number, $0.isVisited) }, uniquingKeysWith: { _, last in last })
        return catalog.map { entry in
            var result = entry
            result.isVisited = progress[entry.number] ?? entry.isVisited
            return result
        }
    }
}

/// A failed decode preserves the original file for recovery before a replacement is saved.
struct CatalogPersistence {
    let directory: URL

    func load<Value: Decodable>(_ type: Value.Type, from filename: String) throws -> Value? {
        let url = directory.appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            // A deterministic recovery copy avoids creating another large file on every launch.
            let backup = directory.appendingPathComponent("\(filename).unreadable")
            if (try? Data(contentsOf: backup)) != data {
                if FileManager.default.fileExists(atPath: backup.path) {
                    let previous = directory.appendingPathComponent("\(filename).unreadable-\(UUID().uuidString)")
                    try FileManager.default.moveItem(at: backup, to: previous)
                }
                try data.write(to: backup, options: .atomic)
            }
            throw error
        }
    }

    func save<Value: Encodable>(_ value: Value, to filename: String) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try JSONEncoder().encode(value).write(to: directory.appendingPathComponent(filename), options: .atomic)
    }
}
