# Views Directory

The `Views` directory contains all the user interface components and view management files for the Poly Canyon app. These files handle the presentation logic, user interactions, and navigation within the app.

## Files

### 1. `ContentView.swift`

**Description:**
Serves as the entry point of the Poly Canyon app, managing the initial user interface based on onboarding status. Utilizes `@AppStorage` to persist user preferences such as onboarding completion, dark mode, and adventure mode. Switches between `OnboardingView` and `MainView` depending on whether the user has completed the onboarding process.

### 2. `MainView.swift`

**Description:**
Acts as the primary interface of the Poly Canyon app, facilitating navigation between different sections such as `MapView`, `DetailView`, and `SettingsView`. Integrates various managers including `LocationManager`, `MapPointManager`, and `StructureData` to handle app data and user interactions. Supports dark mode and adventure mode settings, and dynamically hides the tab bar when the keyboard is visible.

**Components:**
- **CustomTabBar:** Provides a custom tab bar for navigation between the main sections of the app, displaying icons for Map, Detail, and Settings views.
- **KeyboardManager:** Observes keyboard visibility changes to manage UI elements accordingly, specifically used to hide the tab bar when the keyboard is visible.

### 3. `OnboardingView.swift`

**Description:**
Guides new users through the onboarding process of the Poly Canyon app. Consists of three main slides:
- **Welcome Slide:** Introduces the app and its purpose.
- **Location Request Slide:** Requests location permissions to enhance user experience.
- **Mode Selection Slide:** Allows users to choose between Adventure Mode and Virtual Tour Mode.
Utilizes `OnboardingLocationManager` to handle location-related functionalities during onboarding.

**Components:**
- **ModeIcon:** Displays an icon representing the selected experience mode with an animated background.
- **CustomModePicker:** Provides a toggle interface for users to switch between Adventure Mode and Virtual Tour Mode.
- **ModeButton:** Represents an individual button within the `CustomModePicker`, allowing users to select a specific mode.
- **RecommendationLabel:** Displays a label indicating whether the selected mode is recommended based on the user's proximity to Cal Poly.
- **PulsingLocationDot:** Animates a pulsing dot to visually indicate active location tracking during the onboarding process.
- **NavigationButton:** A styled button used within the onboarding slides for navigation purposes.
- **PulseAnimation:** A view modifier that applies a scaling pulsing animation to the content.

## Usage

- **ContentView.swift:** Determines whether to present the onboarding process or the main interface based on user completion status.
- **MainView.swift:** Manages the core navigation and integrates various data managers to ensure seamless user interactions.
- **OnboardingView.swift:** Provides an engaging onboarding experience, ensuring users set up their preferences and permissions before accessing the main features of the app.

