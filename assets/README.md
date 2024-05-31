# Assets

This directory contains all assets used in the app. 


# Assets Structure

The following subdirectories are present

```
assets/
├── app icon/       
├── data/ 
├── map/  
├── onboarding/   
├── photos/
├── screenshots/
```

### App Icon

Contains all different sizes and Photoshop files of the app icon used. Current sizes match those required on iOS.

### Data

Contains the CSV file of data used in the app.

- **[mapPoints.csv](data/mapPoints.csv):** Contains information about the points where a user's location can appear on the map. Each map point has:
  - **Coordinate Point:** Links to a real-world location.
  - **Pixel Position:** Shows their location on the mapView based on the closest coordinate.
  - **Landmark:** Points to a structure's number or -1 if it isn't at a structure.

- **[structures.csv](data/structures.csv):** Contains information about the structures in Poly Canyon. Each structure entry has:
  - **Number:** Corresponds to the map number.
  - **Name:** The actual name of the structure.
  - **Description:** In-depth explanation of the details of the structure.
  - **Year:** Optional value of the year the structure was built.

### Map

Includes JPG and Photoshop files for Light, Dark, and Satellite Maps.

- **JPG:** Contains the JPG files of each map.
  - **[Full size](map/jpg/full%20size):** Each map at a 1.5x scale of the Photoshop file (5529 x 12492px).
  - **[Small](map/jpg/small):** Each map at a 0.5 scale, size used in the app for optimization (1843 x 4164px).
  - **[BlurredSatellite.jpg](map/jpg/BlurredSatellite.jpg):** The background image displayed when the satellite map is toggled in the app.

- **Photoshop:** Contains the Photoshop files of each map.
  - **[WhiteMap.psd](map/photoshop/WhiteMap.psd), [DarkMap.psd](map/photoshop/DarkMap.psd), [SatelliteMap.psd](map/photoshop/SatelliteMap.psd):** Photoshop files of the light, dark, and satellite maps.
  - **[MapPoints.psd](map/photoshop/MapPoints.psd):** Photoshop representation showing the pixel positions of every single map point from mapPoints.csv.

### Onboarding

Includes JPG and Photoshop files of the three onboarding processes:
- **[Main.jpg](onboarding/jpg/Main.jpg):** Onboarding screen shown the first time you open the app.
- **[Map.jpg](onboarding/jpg/Map.jpg):** Onboarding popup shown the first time you visit the map page.
- **[Detail.jpg](onboarding/jpg/Detail.jpg):** Onboarding popup shown the first time you visit the detail page.

### Photos

JPG images of smaller size (1400 x 2100px), each named 1-35 to correspond to the structure they depict:
- **Close:** Closeup photos in the [Close](photos/Close) folder.
- **Main:** Main photos in the [Main](photos/Main) folder.

### Screenshots

PNG images of all different screens in the app, captured using a simulator


