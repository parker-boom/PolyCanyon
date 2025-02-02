import firestore from "@react-native-firebase/firestore";
import AsyncStorage from "@react-native-async-storage/async-storage";
import uuid from "react-native-uuid";

class FirebaseService {
  // Retrieves or generates a unique user ID
  static async getUserId() {
    try {
      // Attempt to get existing user ID from AsyncStorage
      let userId = await AsyncStorage.getItem("userId");
      if (!userId) {
        // If no existing ID, generate a new one and store it
        userId = uuid.v4();
        await AsyncStorage.setItem("userId", userId);
      }
      return userId;
    } catch (error) {
      console.error("Error getting/generating user ID:", error);
      return null;
    }
  }

  // Logs user location to Firestore
  static async logLocation(mapPoint, userId) {
    if (!userId) {
      console.error("No user ID available for logging location");
      return;
    }

    try {
      // Add location data to Firestore
      const docRef = await firestore().collection("user_locations").add({
        latitude: mapPoint.latitude,
        longitude: mapPoint.longitude,
        timestamp: firestore.FieldValue.serverTimestamp(),
        userId: userId,
      });
    } catch (error) {
      console.error("Error logging location to Firebase:", error);
    }
  }
}

export default FirebaseService;
