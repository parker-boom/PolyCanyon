# Swift

This directory contains all files for the Swift application, developed using Xcode 16 and SwiftUI.

## Swift Structure

```
swift/
├── Poly Canyon.xcodeproj/    # Contains the Xcode Project File     
├── Poly Canyon/              # Contains all necessary files and assets 
│   ├── Views/                 # Contains all SwiftUI view components
│   │   ├── ContentView.swift
│   │   ├── MainView.swift
│   │   ├── OnboardingView.swift
│   │   ├── Main Views/
│   │   │   ├── DetailView.swift
│   │   │   ├── MapView.swift
│   │   │   ├── SettingsView.swift
│   │   │   ├── StructPopUp.swift
│   │   │   ├── StructureSwipingView.swift
│   ├── Data/                  # Contains all data management files
│   │   ├── LocationManager.swift
│   │   ├── OnboardingLocationManager.swift
│   │   ├── StructureData.swift
│   │   ├── MapPointManager.swift
```

## Subdirectories

### Views

The `Views` directory encompasses all user interface components and view management files for the Poly Canyon app. These files handle the presentation logic, user interactions, and navigation within the app.

- **Contents:**
  - **ContentView.swift:** Entry point that manages the initial user interface based on onboarding status.
  - **MainView.swift:** Primary interface facilitating navigation between different sections like MapView, DetailView, and SettingsView.
  - **OnboardingView.swift:** Guides new users through the onboarding process with informative slides.
  - **Main Views/**: Contains core views such as DetailView, MapView, SettingsView, StructPopUp, and StructureSwipingView.
  - **Components/**: Includes reusable UI components like CustomTabBar and KeyboardManager.

For detailed information about each component and view, refer to the [Views README](./PolyCanyon/Views/README.md).

### Data

The `Data` directory is responsible for all data management within the Poly Canyon app. It handles location services, manages structural data, and oversees map points used throughout the application.

- **Contents:**
  - **LocationManager.swift:** Manages location services, tracking user location, handling authorization, and interfacing with map points and structures.
  - **OnboardingLocationManager.swift:** Handles location services specifically during the onboarding phase, ensuring users provide necessary location data.
  - **StructureData.swift:** Manages the collection of structures, including loading data from CSV files and persisting user interactions like visits and likes.
  - **MapPointManager.swift:** Manages map points, including loading from CSV, persisting visited statuses, and providing functionalities to reset or update visit statuses.

For more comprehensive details on data management and functionalities, refer to the [Data README](./Poly_Canyon/Data/README.md).

## Summary

This README provides an overview of the SwiftUI view components and data management files within the Poly Canyon app. The `Views` directory handles all aspects of the user interface and interactions, while the `Data` directory manages location services, structural data, and map points. Each subdirectory is structured to ensure a cohesive and responsive user experience, with separate READMEs available for in-depth information.
