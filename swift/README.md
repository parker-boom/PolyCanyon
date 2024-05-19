# Swift

This directory contains all files for the Swift application, coded in Xcode 16 and SwiftUI.

## Swift Structure
```
swift /
├── Poly Canyon.xcodeproj/    # Contains actual Xcode Project File     
├── Poly Canyon/              # Contains all needed files and assets 
├── Poly CanyonTests/         # /Not Used/
├── Poly CanyonUITests/       # /Not Used/ 
```



### Poly Canyon.xcodeproj

Xcode project file. Open this to see the development environment. Requires Xcode 17 to deploy.

### Poly Canyon

Data and assets are the same as in the ./Assets directory, just imported for Xcode processes. Preview Content & Poly_CanyonApp can generally be ignored and should almost never change.

### Views

Contains SwiftUI and Swift files for the project. The hierarchy is:
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


## File Details


#### ContentView.swift

Entry point for the UI. Controls the flow between onboarding and main content views based on user preferences and first-launch detection.

- **Features:**
  - Stores user preferences for themes and modes using `@AppStorage`.
  - Conditionally renders `OnboardingView` or `MainView` based on `isFirstLaunch`.

#### MainView.swift

Primary interface after onboarding, orchestrates navigation through a tab view setup.

- **Features:**
  - Integrates `MapView`, `DetailView`, and `SettingsView` in a tab view.
  - Customized tab bar with dynamic styling based on dark mode setting.

#### OnboardingView.swift

Provides onboarding information to users when they first launch the app.

### Main Views

#### DetailView.swift

Displays detailed information about each structure. Offers a dynamic view switch between grid and list layout.

- **Features:**
  - Dynamic search functionality for filtering structures.
  - Switchable view modes between grid and list.
  - Onboarding and tutorial overlays for first-time users.
  - Reactive UI and data model updates, especially in adventure mode.

#### MapView.swift

Interactive and dynamic map interface for users to explore Poly Canyon. Integrates CoreLocation for tracking and updating user positions.

- **Features:**
  - Dynamic map scaling and panning.
  - Conditional rendering based on user settings for dark mode and satellite view.
  - Location-based alerts and onboarding.
  - Custom pulsing circle animation for current location.

#### SettingsView.swift

Allows users to customize their app experience through toggles and informational links.

- **Features:**
  - Toggles for dark mode and adventure mode.
  - Buttons for resetting visited structures and setting conditions based on adventure mode.
  - Links to external resources for more information about Poly Canyon.
  - Credits section for contributors and app development context.

#### StructPopUp.swift

Detailed view displaying information about a specific structure when interacted with.

- **Features:**
  - Dynamic image switching based on user gestures.
  - Detailed textual content about the structure's background, design, and significance.
  - Environmental presentation mode for modal view dismissal.
  - Adaptive color changes for text and background based on dark mode setting.

### Data 

#### LocationManager.swift

Handles location functionalities using CoreLocation.

- **Features:**
  - Adaptive location update frequencies.
  - Geofencing for entry and exit notifications.
  - Tracking and updating visited landmarks.

#### StructureData.swift

Manages and persists data related to structures.

- **Features:**
  - Loads and saves structure data to `UserDefaults`.
  - Resets visited structures and marks all structures as visited.
  - Imports initial data from a CSV file.

#### mapPoints.swift

Defines the `MapPoint` structure and array of map points.

- **Features:**
  - Contains geographic coordinates, pixel positions, and landmark identifiers for structures.
