// MARK: StructureData.swift
// This file defines the StructureData class in the "Arch Graveyard" app, which is responsible for managing and persisting data related to architectural structures. It uses @Published to observe changes in the structures array, saving data to UserDefaults for persistence across app launches.

// Key functionalities include:
// - Loading and saving structure data to UserDefaults.
// - Resetting visited structures and marking all structures as visited, useful for settings and toggling adventure mode.
// - Importing initial data from a CSV file to populate the structures list when starting the app or when no saved data is available.





// MARK: Code
import Foundation

class StructureData: ObservableObject {
    @Published var structures: [Structure] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    // call to load across app closes
    init() {
        loadFromUserDefaults()
    }
    
    // save things to user default
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(structures) {
            UserDefaults.standard.set(encoded, forKey: "structures")
        }
    }

    // load things from user defaults
    func loadFromUserDefaults() {
        if let structuresData = UserDefaults.standard.data(forKey: "structures"),
           let decodedStructures = try? JSONDecoder().decode([Structure].self, from: structuresData) {
            self.structures = decodedStructures
        } else {
            loadStructuresFromCSV()
        }
    }
    
    // reset visited structuress - triggered in settings
    func resetVisitedStructures() {
        for index in structures.indices {
            structures[index].isVisited = false
            structures[index].isOpened = false
        }
        objectWillChange.send()
    }
    
    // set all structures as visited - triggered when adventure mode turned off
    func setAllStructuresAsVisited() {
        structures = structures.map { structure in
            var updatedStructure = structure
            updatedStructure.isVisited = true
            return updatedStructure
        }
    }
    
    // use structures.csv to load the data
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
