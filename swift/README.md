# Swift

This directory contains all files for the Swift application. Coded in Xcode16 and SwiftUI. 


# Swift Structure

The following subdirectories are present

```
swift /
├── Poly Canyon.xcodeproj/    # Contains actual Xcode Project File     
├── Poly Canyon/              # Contains all needed files and assets 
├── Poly CanyonTests/         # /Not Used/
├── Poly CanyonUITests/       # /Not Used/ 
```


## Poly Canyon.xcodeproj

Contains the project file for the XCode project. Open this to see development environment. Need Xcode17 to deploy. 


##  Poly Canyon 

Data and Assets contain the same files that are in the ./Assets directory, just imported in for Xcode Processes. 
Preview Content & Poly_CanyonApp can generally be ignored and should almost never change. 

### Views
Views contains the important SwiftUI and Swift files for the project. The following hierarchy is used. 

```
swift/Poly Canyon/Views /
├── ContentView            # Displays either the MainView or OnboardingView depending if it is first launch
├── MainView               # Tab view hierarchy holding Detail, Map, Settings views
├── OnboardingView         # Simple image that gives onboarding information

├── /Main Views            # Contains the actual views the user sees
├───── DetailView          # View showing off all structures 
├───── MapView             # View showing off the map
├───── SettingsView        # View showing off the settings
'───── StructPopUp         # Pop-up view used to show detail information on structures

├── /Data                  # Contains the data-based non-UI files
├───── LocationManager     # Manages location data, permissions, and links between views
├───── StructureData       # Reads and manages structure data from CSV
├───── mapPoints           # Reads and manages mapPoints data from CSV
```

### 
