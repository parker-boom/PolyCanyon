# Data Directory

The `Data` directory contains all the essential data management files for the Poly Canyon app. This includes handling location services, managing structural data, and overseeing map points used within the application.

## Files

### 1. `LocationManager.swift`

**Description:**
Manages location services for the Poly Canyon app, including tracking user location, handling authorization status, logging locations to Firebase, and managing user interactions with map points and structures. It supports both foreground and background location updates based on the Adventure Mode status.

### 2. `OnboardingLocationManager.swift`

**Description:**
Handles location services during the onboarding phase of the Poly Canyon app. It manages location permissions, fetches the user's current location, and determines if the user is near the Cal Poly campus. This ensures that users provide necessary location data to enhance their app experience.

### 3. `StructureData.swift`

**Description:**
Manages the collection of structures within the Poly Canyon app. This class handles loading structure data from a CSV file, persisting user interactions like visits and likes using UserDefaults, and providing methods to manipulate and query the structure data.

### 4. `MapPointManager.swift`

**Description:**
Manages the collection of MapPoint instances within the Poly Canyon app. This class handles loading map points from a CSV file, persisting visited statuses using UserDefaults, and providing functionalities to reset or update the visited status of map points.
