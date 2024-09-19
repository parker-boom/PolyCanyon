// MARK: StructureData.swift

import Foundation

/**
 * Structure
 *
 * Represents a structural entity within the Poly Canyon app, encapsulating details such as
 * the structure's number, title, description, year of construction, builders, fun facts,
 * associated photos, and user interaction states like visited status and likes.
 */
struct Structure: Identifiable, Codable {
    let number: Int
    let title: String
    let description: String
    let year: String
    let builders: String
    let funFact: String
    let mainPhoto: String
    let closeUp: String
    var isVisited: Bool
    var isOpened: Bool
    var recentlyVisited: Int
    var isLiked: Bool

    var id: Int { number }
}

/**
 * StructureData
 *
 * Manages the collection of structures within the Poly Canyon app. This class handles
 * loading structure data from a CSV file, persisting user interactions like visits and likes
 * using UserDefaults, and providing methods to manipulate and query the structure data.
 */
class StructureData: ObservableObject {
    @Published var structures: [Structure] = []
    @Published var isLoading: Bool = true
    
    private let structuresKey = "persistedStructures"

    /**
     * Initializes the StructureData manager and loads structure data.
     */
    init() {
        loadData()
    }

    /**
     * Loads structure data either from persisted storage or from a CSV file.
     */
    private func loadData() {
        self.isLoading = true
        
        if let savedStructures = loadFromUserDefaults() {
            self.structures = savedStructures
            self.isLoading = false
        } else {
            loadStructuresFromCSV()
        }
    }

    /**
     * Loads structure data from UserDefaults if available.
     *
     * - Returns: An array of Structure objects if available, otherwise nil.
     */
    private func loadFromUserDefaults() -> [Structure]? {
        if let structuresData = UserDefaults.standard.data(forKey: structuresKey),
           let decodedStructures = try? JSONDecoder().decode([Structure].self, from: structuresData) {
            return decodedStructures
        }
        return nil
    }

    /**
     * Saves the current structures to UserDefaults for persistence.
     */
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(structures) {
            UserDefaults.standard.set(encoded, forKey: structuresKey)
        }
    }
    
    /**
     * Checks whether a specific structure has been visited based on its index.
     *
     * - Parameter index: The index of the structure in the structures array.
     * - Returns: A Boolean indicating if the structure has been visited.
     */
    func checkVisitedStatus(index: Int) -> Bool {
        guard index >= 0 && index < structures.count else {
            print("DEBUG: Invalid index for checkVisitedStatus: \(index)")
            return false
        }
        let isVisited = structures[index].isVisited
        print("DEBUG: Checking visited status for structure \(structures[index].number): \(isVisited)")
        return isVisited
    }

    /**
     * Loads structures from a CSV file and updates the structures array.
     * Parses each line of the CSV to create Structure objects.
     */
    func loadStructuresFromCSV() {
        guard let url = Bundle.main.url(forResource: "structures", withExtension: "csv") else {
            print("Error: Cannot find structures.csv file")
            return
        }
        
        do {
            let csvData = try Data(contentsOf: url)
            let csvString = String(data: csvData, encoding: .utf8) ?? ""
            let lines = csvString.components(separatedBy: .newlines)
            
            var loadedStructures: [Structure] = []
            
            for line in lines.dropFirst() {
                let values = csvScanner(line: line)
                if values.count >= 6 {
                    let number = Int(values[0]) ?? 0
                    let title = values[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    let year = values[2].trimmingCharacters(in: .whitespacesAndNewlines)
                    let builders = values[3].trimmingCharacters(in: .whitespacesAndNewlines)
                    let funFact = values[4].trimmingCharacters(in: .whitespacesAndNewlines)
                    let description = values[5].trimmingCharacters(in: .whitespacesAndNewlines)
                    let mainPhoto = "\(number)M"
                    let closeUp = "\(number)C"
                    
                    let structure = Structure(
                        number: number,
                        title: title,
                        description: description,
                        year: year,
                        builders: builders,
                        funFact: funFact,
                        mainPhoto: mainPhoto,
                        closeUp: closeUp,
                        isVisited: false,
                        isOpened: false,
                        recentlyVisited: -1,
                        isLiked: false
                    )
                    loadedStructures.append(structure)
                }
            }
            
            DispatchQueue.main.async {
                self.structures = loadedStructures
                self.saveToUserDefaults()
                self.isLoading = false
            }
        } catch {
            print("Error reading CSV file: \(error)")
            self.isLoading = false
        }
    }

    /**
     * Parses a single line of CSV, handling quoted fields and commas.
     *
     * - Parameter line: A string representing a line from the CSV file.
     * - Returns: An array of strings representing the fields in the CSV line.
     */
    private func csvScanner(line: String) -> [String] {
        var result: [String] = []
        var currentField = ""
        var insideQuotes = false
        
        for character in line {
            switch character {
            case "\"":
                insideQuotes.toggle()
            case ",":
                if insideQuotes {
                    currentField.append(character)
                } else {
                    result.append(currentField)
                    currentField = ""
                }
            default:
                currentField.append(character)
            }
        }
        
        result.append(currentField)
        return result
    }

    /**
     * Resets the visited and opened status of all structures.
     * Also resets the recentlyVisited count.
     */
    func resetVisitedStructures() {
        for index in structures.indices {
            structures[index].isVisited = false
            structures[index].isOpened = false
            structures[index].recentlyVisited = -1
        }
        saveToUserDefaults()
        objectWillChange.send()
    }

    /**
     * Determines if any structures have been liked by the user.
     *
     * - Returns: A Boolean indicating if at least one structure has been liked.
     */
    func hasRatedStructures() -> Bool {
        return structures.contains { $0.isLiked }
    }

    /**
     * Marks all structures as visited.
     */
    func setAllStructuresAsVisited() {
        for index in structures.indices {
            structures[index].isVisited = true
        }
        saveToUserDefaults()
        objectWillChange.send()
    }
    
    /**
     * Ensures a specific structure is marked as visited based on its number.
     *
     * - Parameter number: The unique number identifier of the structure.
     */
    func ensureStructureVisited(_ number: Int) {
        if let index = structures.firstIndex(where: { $0.number == number }) {
            structures[index].isVisited = true
        }
    }

    /**
     * Resets the like status of all structures.
     */
    func resetFavorites() {
        for index in structures.indices {
            structures[index].isLiked = false
        }
        saveToUserDefaults()
        objectWillChange.send()
    }

    /**
     * Toggles the like status of a specific structure.
     *
     * - Parameter structureId: The unique identifier of the structure to toggle.
     */
    func toggleLike(for structureId: Int) {
        if let index = structures.firstIndex(where: { $0.id == structureId }) {
            structures[index].isLiked.toggle()
            saveToUserDefaults()
        }
    }

    /**
     * Retrieves all structures that have been liked by the user.
     *
     * - Returns: An array of Structure objects that are liked.
     */
    func getLikedStructures() -> [Structure] {
        return structures.filter { $0.isLiked }
    }
    
    /**
     * Marks a specific structure as visited and updates the recentlyVisited count.
     *
     * - Parameters:
     *   - number: The unique number identifier of the structure.
     *   - recentlyVisitedCount: The count representing how recently the structure was visited.
     */
    func markStructureAsVisited(_ number: Int, recentlyVisitedCount: Int) {
        print("DEBUG: Attempting to mark structure \(number) as visited")
        if let index = structures.firstIndex(where: { $0.number == number }) {
            structures[index].isVisited = true
            if structures[index].recentlyVisited == -1 {
                structures[index].recentlyVisited = recentlyVisitedCount
            }
            print("DEBUG: Structure \(number) marked as visited. Recently visited count: \(recentlyVisitedCount)")
            saveToUserDefaults()
            objectWillChange.send()
        } else {
            print("DEBUG: Failed to find structure with number \(number)")
        }
    }
    
    /**
     * Marks a specific structure as opened.
     *
     * - Parameter number: The unique number identifier of the structure.
     */
    func markStructureAsOpened(_ number: Int) {
        if let index = structures.firstIndex(where: { $0.number == number }) {
            structures[index].isOpened = true
            saveToUserDefaults()
            objectWillChange.send()
        }
    }
}
