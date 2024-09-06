import Foundation

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

class StructureData: ObservableObject {
    @Published var structures: [Structure] = []
    private let currentDataVersion = 5
    @Published var dataVersion: Int = 0
    @Published var isLoading: Bool = true

    init() {
        loadData()
    }
    

    private func loadData() {
        self.isLoading = true
        self.dataVersion = UserDefaults.standard.integer(forKey: "structuresDataVersion")
        
        if dataVersion != currentDataVersion {
            reloadStructures()
        } else {
            loadFromUserDefaults()
        }
    }

    
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(structures) {
            UserDefaults.standard.set(encoded, forKey: "structures")
            UserDefaults.standard.set(dataVersion, forKey: "structuresDataVersion")
        }
    }
    
    private func loadFromUserDefaults() {
        if let structuresData = UserDefaults.standard.data(forKey: "structures"),
           let decodedStructures = try? JSONDecoder().decode([Structure].self, from: structuresData) {
            DispatchQueue.main.async {
                self.structures = decodedStructures
                self.isLoading = false
            }
        } else {
            reloadStructures()
        }
    }
    
    private func reloadStructures() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.clearExistingData()
            self?.loadStructuresFromCSV()
            DispatchQueue.main.async {
                self?.dataVersion = self?.currentDataVersion ?? 0
                self?.saveToUserDefaults()
                self?.isLoading = false
            }
        }
    }
    
    private func clearExistingData() {
        structures.removeAll()
    }
    
    func resetVisitedStructures() {
        for index in structures.indices {
            structures[index].isVisited = false
            structures[index].isOpened = false
            structures[index].recentlyVisited = -1
        }
        objectWillChange.send()
    }
    
    func setAllStructuresAsVisited() {
        structures = structures.map { structure in
            var updatedStructure = structure
            updatedStructure.isVisited = true
            return updatedStructure
        }
    }
    
    func resetFavorites() {
        for index in structures.indices {
            structures[index].isLiked = false
        }
        objectWillChange.send()
    }
    
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
            }
        } catch {
            print("Error reading CSV file: \(error)")
        }
    }
    
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
        
        // Add the last field
        result.append(currentField)
        
        return result
    }
    
    func toggleLike(for structureId: Int) {
        if let index = structures.firstIndex(where: { $0.id == structureId }) {
            structures[index].isLiked.toggle()
        }
    }
    
    func getLikedStructures() -> [Structure] {
        return structures.filter { $0.isLiked }
    }
}
