import firestore from '@react-native-firebase/firestore';
import AsyncStorage from '@react-native-async-storage/async-storage';
import uuid from 'react-native-uuid';

class FirebaseService {
    static async getUserId() {
        try {
            let userId = await AsyncStorage.getItem('userId');
            if (!userId) {
                userId = uuid.v4();
                await AsyncStorage.setItem('userId', userId);
            }
            return userId;
        } catch (error) {
            console.error("Error getting/generating user ID:", error);
            return null;
        }
    }

    static async logLocation(mapPoint, userId) {
        if (!userId) {
            console.error("No user ID available for logging location");
            return;
        }

        try {
            const docRef = await firestore().collection('user_locations').add({
                latitude: mapPoint.latitude,
                longitude: mapPoint.longitude,
                timestamp: firestore.FieldValue.serverTimestamp(),
                userId: userId
            });
            console.log("Location logged to Firebase. Document ID:", docRef.id);
        } catch (error) {
            console.error("Error logging location to Firebase:", error);
        }
    }
}

export default FirebaseService;