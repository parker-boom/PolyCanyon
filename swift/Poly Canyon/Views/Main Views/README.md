# MainViews Directory

## Overview

The `MainViews` directory is a core component of the Poly Canyon app, housing the primary SwiftUI views that define the main user interface and interactions. This directory includes the following key views:

- [DetailView](#detailview)
- [MapView](#mapview)
- [SettingsView](#settingsview)
- [StructPopUp](#structpopup)
- [StructureSwipingView](#structureswipingview)

Each view is meticulously designed to provide a seamless and intuitive user experience, leveraging SwiftUI's capabilities for dynamic and responsive design. This README provides an in-depth overview of each view, their functionalities, and how they integrate within the app.

---

## DetailView

### Purpose

`DetailView` presents comprehensive information about a specific structure within Poly Canyon. It serves as the primary interface for users to explore detailed descriptions, images, and other relevant data about each structure.

### Key Components

- **Image Carousel:** Displays a series of images related to the structure, allowing users to swipe through them.
- **Description Section:** Provides an in-depth narrative about the structure, its history, significance, and other pertinent details.
- **Statistics:** Showcases metrics such as the number of visitors, construction year, and other relevant data.
- **Like Button:** Enables users to like or favorite a structure for easy access later.
- **Action Buttons:** Includes options like sharing the structure details or adding it to favorites.

### Integration

`DetailView` is typically navigated to from a list or map view where users select a specific structure to explore further.

---

## MapView

### Purpose

`MapView` offers an interactive map interface displaying the geographical locations of all structures within Poly Canyon. It facilitates easy navigation and exploration, allowing users to locate structures, get directions, and visualize their proximity.

### Key Components

- **Map Annotations:** Pins or markers representing each structure's location.
- **User Location Tracking:** Displays the user's current location on the map.
- **Search Functionality:** Allows users to search for specific structures or filter them based on criteria.
- **Route Planning:** Provides directions from the user's location to a selected structure.
- **Interactive Elements:** Tappable annotations that lead to `DetailView` for more information.

### Integration

`MapView` is accessible from the main menu or dashboard, providing a spatial context to the structures listed in the app.

---

## SettingsView

### Purpose

`SettingsView` offers users the ability to customize their app experience. It includes options to toggle themes, manage preferences, reset data, and access additional information about the app.

### Key Components

- **Dark Mode Toggle:** Allows users to switch between light and dark themes.
- **Adventure Mode Toggle:** Enables or disables adventure mode, altering the app's functionality.
- **Reset Options:** Provides options to reset visited structures or favorites.
- **Statistics:** Displays user-specific metrics like the number of visited structures and days engaged.
- **Information Buttons:** Links to guides like "How to Get There" or "Pick Your Favorites."
- **Credits Section:** Acknowledges the developers, institutions, and provides contact information for support.

### Integration

`SettingsView` is accessible from the main menu or dashboard, offering a centralized location for all user preferences and configurations.

---

## StructPopUp

### Purpose

`StructPopUp` is a modal view that provides detailed information about a selected structure in a visually appealing popup format. It enhances user engagement by offering rich content without navigating away from the current view.

### Key Components

- **Image Carousel:** Swipeable images showcasing the structure from different angles.
- **Like Button:** Allows users to like or favorite the structure directly from the popup.
- **Information Panel:** Reveals detailed information, including builders, fun facts, and descriptions.
- **Dismiss Gesture:** Users can swipe down or tap the close button to dismiss the popup.
- **Dark Mode Support:** Adapts the popup's appearance based on the app's theme.

### Integration

`StructPopUp` is triggered from `DetailView` or `MapView` when a user selects a structure, providing an immediate and immersive overview.

---

## StructureSwipingView

### Purpose

`StructureSwipingView` offers an interactive swiping interface where users can browse through structures, liking or disliking them as they swipe. This feature gamifies the exploration process, making it engaging and intuitive.

### Key Components

- **Swipeable Cards:** Each card represents a structure with its image and title.
- **Like/Dislike Buttons:** Allows users to express their preference by swiping or tapping.
- **Progress Tracking:** Keeps track of how many structures have been rated.
- **Completion View:** Summarizes the user's preferences upon finishing the swiping session.
- **Persistence:** Saves the user's progress to allow resuming later.
- **Dark Mode Support:** Ensures the interface is consistent with the app's theme.

### Integration

`StructureSwipingView` is accessible from the `SettingsView` or a dedicated section in the main menu, encouraging users to rate and engage with the structures.
