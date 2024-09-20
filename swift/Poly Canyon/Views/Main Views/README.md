MainViews Directory

## Files

### DetailView.swift

**Description:**  
`DetailView` is a SwiftUI view that displays a list of structures, allowing users to search, sort, and view structures in grid or list formats. It includes features such as search functionality, sorting by different criteria (e.g., favorites, visited), and detailed popups for each structure. The view adapts to dark mode and supports adventure mode, providing additional filtering options based on user preferences.

**Key Components:**
- Search bar with custom styling
- Sort button with filtering options
- Grid and list views for displaying structures
- Popups for recently visited, unopened, and nearby unvisited structures
- Location-based distance calculations

### MapView.swift

**Description:**  
`MapView` presents a navigable map interface for the Poly Canyon app, integrating location services to display the user's position and nearby structures. Users can interact with the map through zoom and drag gestures, toggle between satellite and standard map views, and access features like virtual walkthroughs. The view handles various user interactions and popups related to structure visits and adventure mode.

**Key Components:**
- Zoomable and draggable map with location dot
- Toggle for satellite and standard map views
- Buttons for nearby unvisited structures and virtual walkthrough
- Popups and alerts for adventure mode and rate structures
- Integration with location services and user statistics

### SettingsView.swift

**Description:**  
`SettingsView` offers a settings interface for users to customize their experience within the Poly Canyon app. Users can toggle Dark Mode and Adventure Mode, reset visited structures or favorites, view user statistics, and access additional information and credits. The view includes confirmation alerts for critical actions and adapts its layout based on dark mode preferences.

**Key Components:**
- Toggles for Dark Mode and Adventure Mode
- Buttons to reset visited structures or favorites
- User statistics display (e.g., visited count, days visited)
- Information section with guides or favorite selection
- Credits section with developer and contact information
- Custom alerts for confirmation

### StructPopUp.swift

**Description:**  
`StructPopUp` is a view that displays detailed information about a selected structure. It features a swipeable image carousel with main and close-up images, an animated information panel with structure details, a like button, and a custom tab selector for stats and descriptions. The popup supports dark mode and is designed to be presented as a sheet, adapting to various device screen sizes.

**Key Components:**
- Swipeable image carousel with indicators
- Dismiss button and structure information overlay
- Like button to mark favorite structures
- Information panel with description, builders, and fun facts
- Animated transitions between image and info views

### StructureSwipingView.swift

**Description:**  
`StructureSwipingView` allows users to swipe through structures to like or dislike them, facilitating the rating process. It includes swipeable cards with like/dislike functionality, progress tracking with indicators, and a completion view summarizing the user's liked structures. The view supports dark mode and provides options to restart the rating or exit the swiping process.

**Key Components:**
- Swipeable cards for each structure
- Like and dislike buttons with gesture handling
- Progress indicators and completion summary
- Persistence of rating progress using `UserDefaults`
- Integration with the `StructureData` model
