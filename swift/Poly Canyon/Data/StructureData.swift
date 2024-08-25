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

class StructureData: ObservableObject {
    @Published var structures: [Structure] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    
    // Call to load across app closes
    init() {
        loadFromUserDefaults()
    }
    
    // Save things to user default
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(structures) {
            UserDefaults.standard.set(encoded, forKey: "structures")
        }
    }

    // Load things from user defaults
    func loadFromUserDefaults() {
        if let structuresData = UserDefaults.standard.data(forKey: "structures"),
           let decodedStructures = try? JSONDecoder().decode([Structure].self, from: structuresData) {
            self.structures = decodedStructures
        } else {
            loadStructuresFromCSV()
        }
        
    }
    
    // Reset visited structuress - triggered in settings
    func resetVisitedStructures() {
        for index in structures.indices {
            structures[index].isVisited = false
            structures[index].isOpened = false
            structures[index].recentlyVisited = -1
        }
        objectWillChange.send()
    }
    
    // Set all structures as visited - triggered when adventure mode turned off
    func setAllStructuresAsVisited() {
        structures = structures.map { structure in
            var updatedStructure = structure
            updatedStructure.isVisited = true
            return updatedStructure
        }
        objectWillChange.send()

    }
    
    // Use structures.csv to load the data
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
                if values.count >= 4 {
                    let number = Int(values[0]) ?? 0
                    let title = values[1]
                    let description = values[2]
                    let year = values[3]
                    let imageName = "\(number)M"
                    let closeUp = "\(number)C"
                    
                    let structure = Structure(number: number, title: title, imageName: imageName, closeUp: closeUp, description: description, year: year)
                    loadedStructures.append(structure)
                }
            }
            
            
            

            DispatchQueue.main.async {
                self.structures = loadedStructures
            }
        } catch {
            print("Error reading CSV file: \(error)")
        }
    }
}
