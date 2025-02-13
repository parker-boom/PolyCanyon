# Poly Canyon App
## Explore Like Never Before
![Poly Canyon Logo](path/to/logo.png)

Welcome to the Poly Canyon App – a digital guide designed to help you experience Poly Canyon like never before. Whether you’re wandering through the canyon in person or exploring from afar, this app is your companion in uncovering the hidden stories behind these remarkable structures.

The app is avaliable for free on:
- [The Apple App Store](https://apps.apple.com/us/app/poly-canyon/id6499063781)
- [The Google Play Store](https://play.google.com/store/apps/details?id=com.polycanyon&hl=en_US&pli=1)

---

### What is Poly Canyon?

![Poly Canyon Photo](path/to/logo.png)

Poly Canyon is a landmark of creativity and history at Cal Poly. Over the decades, student-built structures have turned this outdoor space into a living mosaic of art and architecture. However, as time has passed, many of these structures have faded away or fallen into disrepair, and with them, much of their story has become lost. The Poly Canyon App brings these stories back to life by guiding you through the canyon’s rich history. It’s built both to augment your on-site exploration and to provide a meaningful virtual experience if you’re not nearby.

---

### How Does It Work?

#### In-Person Exploration
Imagine stepping into Poly Canyon. In Adventure Mode, the app does the following:
- Automatically tracks when you visit a structure
- Notifies you when you do visit and allows you to learn more
- Shows your location on a live up-to-date interactive map
The app truly augments exploration of the canyon by providing navigational peace of mind and deep historical information.
![In-Person Demo](path/to/in-person-demo.gif)

#### Virtual Visits
Not in the canyon? The Virtual Tour Mode offers a guided digital walkthrough of Poly Canyon’s highlights. You can explore at your own pace, like your favorite spots, and dive into detailed narratives that bring the canyon’s legacy to life.
![Virtual Tour Demo](path/to/virtual-tour-demo.gif)

---

### How was it developed?

Behind the scenes, the Poly Canyon App runs on two codebases—one built with SwiftUI and another with React Native. Both platforms deliver the same smooth, unified experience by relying on three core components:

- **LocationService:**  
  This service handles location permissions and continuously updates a user's position. It loads a set of map points from a JSON file—each with a pixel position and coordinates—and links some of these points to specific structures. When you get close enough, the service triggers actions like marking a structure as visited. This is the core process behind live location features.

- **DataStore:**  
  Think of this as the app’s library of stories. It stores all the details about the 31 unique structures—from static information like descriptions, images, fun facts, and build years, to dynamic data tracking whether you’ve visited or favorited a structure. This is the core process managing all the structures and their information. 

- **AppState:**  
  Acting as the glue that holds it all together, AppState manages UI variables, state flags, and user interactions. It ensures that updates—like live map tracking and user progress—are consistent across the app.

In SwiftUI, these services are shared as environment objects, while in React Native, they’re managed via service providers. A user interacts with the app through 3 main views:
1. MapView: Shows the detailed map of the canyona and displays the user's live location or hosts the virtual tour
2. DetailView: Shows all of the structures of the canyon in a grid view, with sorting and searching abilities
3. InfoView: A full screen view showing detailed information on a single structure and high quality pictures

---

### Final Thoughts

This project is my baby. I worked on every part of it—from designing the logos and thinking through every detail, to teaching myself SwiftUI and React Native, publishing the apps, and even taking the photos used throughout. My goal is not just to build an app, but to revive Poly Canyon’s legacy and kickstart a campaign to reinstate caretakers for this historic site.

Thank you for checking out the Poly Canyon App. I hope it offers you a fresh, engaging way to connect with a truly unique part of Cal Poly’s history.

[Visit the Poly Canyon Website](https://polycanyon.com/)

Happy exploring!
