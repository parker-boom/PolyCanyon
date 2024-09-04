// MARK: Overview
/*
    StructureData.swift

    This file defines the StructureData class, which manages the data for all structures in the app.

    Key Components:
    - Publishes an array of structures, saving changes to UserDefaults.
    - Initializes by loading data from UserDefaults or from a CSV file if no data is found.

    Functionality:
    - saveToUserDefaults(): Encodes and saves the structures array to UserDefaults.
    - loadFromUserDefaults(): Decodes and loads the structures array from UserDefaults.
    - resetVisitedStructures(): Resets the visited status of all structures.
    - setAllStructuresAsVisited(): Marks all structures as visited.
    - loadStructuresFromCSV(): Loads structure data from a CSV file.
*/





// MARK: Code
import Foundation

struct Structure: Identifiable, Codable {
    let number: Int
    let title: String
    let year: String
    let builders: String
    let funFact: String
    let description: String
    let mainPhoto: String
    let closeUp: String
    var isVisited: Bool
    var isOpened: Bool
    var recentlyVisited: Int
    var isLiked: Bool

    var id: Int { number }
}

class StructureData: ObservableObject {
    @Published var structures: [Structure] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private let currentDataVersion = 3
    @Published var dataVersion: Int {
        didSet {
            if dataVersion != currentDataVersion {
                reloadStructures()
                print("reloading finished")
            } else {
                print("huh")
            }
        }
    }
    
    init() {
        self.dataVersion = UserDefaults.standard.integer(forKey: "structuresDataVersion")
        loadFromUserDefaults()
    }
    
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(structures) {
            UserDefaults.standard.set(encoded, forKey: "structures")
            UserDefaults.standard.set(dataVersion, forKey: "structuresDataVersion")
        }
    }
    
    func loadFromUserDefaults() {
        if dataVersion < currentDataVersion {
            reloadStructures()
        } else if let structuresData = UserDefaults.standard.data(forKey: "structures"),
                  let decodedStructures = try? JSONDecoder().decode([Structure].self, from: structuresData) {
            self.structures = decodedStructures
        } else {
            reloadStructures()
        }
    }
    
    func reloadStructures() {
        structures.removeAll()
        loadStructuresFromCSV()
        dataVersion = currentDataVersion
        saveToUserDefaults()
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
    
    func loadStructuresFromCSV() {
        guard let url = Bundle.main.url(forResource: "structures", withExtension: "csv") else {
            return
        }
        
        do {
            let csvData = try Data(contentsOf: url)
            let csvString = String(data: csvData, encoding: .utf8) ?? ""
            let lines = csvString.components(separatedBy: .newlines)
            
            var loadedStructures: [Structure] = []
            
            for line in lines.dropFirst() {
                let values = line.components(separatedBy: ",")
                if values.count >= 7 {
                    let number = Int(values[0]) ?? 0
                    let title = values[1]
                    let year = values[2]
                    let builders = values[3]
                    let funFact = values[4]
                    let description = values[5]
                    let mainPhoto = "\(number)M"
                    let closeUp = "\(number)C"
                    let structure = Structure(
                        number: number,
                        title: title,
                        year: year,
                        builders: builders,
                        funFact: funFact,
                        description: description,
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
    
    func toggleLike(for structureId: Int) {
        if let index = structures.firstIndex(where: { $0.id == structureId }) {
            structures[index].isLiked.toggle()
        }
    }
    
    func getLikedStructures() -> [Structure] {
        return structures.filter { $0.isLiked }
    }
}
