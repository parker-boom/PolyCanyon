import React, { createContext, useState, useContext, useEffect } from 'react';
import rawStructureData from './structures.json'; 
import AsyncStorage from '@react-native-async-storage/async-storage';

const StructureContext = createContext();

export const useStructures = () => useContext(StructureContext);

// Explicitly require each image
const images = {
  // Close-up images
  "C-1": require('../assets/photos/Close/C-1.jpg'),
  "C-2": require('../assets/photos/Close/C-2.jpg'),
  "C-3": require('../assets/photos/Close/C-3.jpg'),
  "C-4": require('../assets/photos/Close/C-4.jpg'),
  "C-5": require('../assets/photos/Close/C-5.jpg'),
  "C-6": require('../assets/photos/Close/C-6.jpg'),
  "C-7": require('../assets/photos/Close/C-7.jpg'),
  "C-8": require('../assets/photos/Close/C-8.jpg'),
  "C-9": require('../assets/photos/Close/C-9.jpg'),
  "C-10": require('../assets/photos/Close/C-10.jpg'),
  "C-11": require('../assets/photos/Close/C-11.jpg'),
  "C-12": require('../assets/photos/Close/C-12.jpg'),
  "C-13": require('../assets/photos/Close/C-13.jpg'),
  "C-14": require('../assets/photos/Close/C-14.jpg'),
  "C-15": require('../assets/photos/Close/C-15.jpg'),
  "C-16": require('../assets/photos/Close/C-16.jpg'),
  "C-17": require('../assets/photos/Close/C-17.jpg'),
  "C-18": require('../assets/photos/Close/C-18.jpg'),
  "C-19": require('../assets/photos/Close/C-19.jpg'),
  "C-20": require('../assets/photos/Close/C-20.jpg'),
  "C-21": require('../assets/photos/Close/C-21.jpg'),
  "C-22": require('../assets/photos/Close/C-22.jpg'),
  "C-23": require('../assets/photos/Close/C-23.jpg'),
  "C-24": require('../assets/photos/Close/C-24.jpg'),
  "C-25": require('../assets/photos/Close/C-25.jpg'),
  "C-26": require('../assets/photos/Close/C-26.jpg'),
  "C-27": require('../assets/photos/Close/C-27.jpg'),
  "C-28": require('../assets/photos/Close/C-28.jpg'),
  "C-29": require('../assets/photos/Close/C-29.jpg'),
  "C-30": require('../assets/photos/Close/C-30.jpg'),
  "C-31": require('../assets/photos/Close/C-31.jpg'),
  "C-32": require('../assets/photos/Close/C-32.jpg'),
  "C-33": require('../assets/photos/Close/C-33.jpg'),
  "C-34": require('../assets/photos/Close/C-34.jpg'),
  "C-35": require('../assets/photos/Close/C-35.jpg'),
  "C-36": require('../assets/photos/Close/C-36.jpg'),
  
  // Main images
  "M-1": require('../assets/photos/Main/M-1.jpg'),
  "M-2": require('../assets/photos/Main/M-2.jpg'),
  "M-3": require('../assets/photos/Main/M-3.jpg'),
  "M-4": require('../assets/photos/Main/M-4.jpg'),
  "M-5": require('../assets/photos/Main/M-5.jpg'),
  "M-6": require('../assets/photos/Main/M-6.jpg'),
  "M-7": require('../assets/photos/Main/M-7.jpg'),
  "M-8": require('../assets/photos/Main/M-8.jpg'),
  "M-9": require('../assets/photos/Main/M-9.jpg'),
  "M-10": require('../assets/photos/Main/M-10.jpg'),
  "M-11": require('../assets/photos/Main/M-11.jpg'),
  "M-12": require('../assets/photos/Main/M-12.jpg'),
  "M-13": require('../assets/photos/Main/M-13.jpg'),
  "M-14": require('../assets/photos/Main/M-14.jpg'),
  "M-15": require('../assets/photos/Main/M-15.jpg'),
  "M-16": require('../assets/photos/Main/M-16.jpg'),
  "M-17": require('../assets/photos/Main/M-17.jpg'),
  "M-18": require('../assets/photos/Main/M-18.jpg'),
  "M-19": require('../assets/photos/Main/M-19.jpg'),
  "M-20": require('../assets/photos/Main/M-20.jpg'),
  "M-21": require('../assets/photos/Main/M-21.jpg'),
  "M-22": require('../assets/photos/Main/M-22.jpg'),
  "M-23": require('../assets/photos/Main/M-23.jpg'),
  "M-24": require('../assets/photos/Main/M-24.jpg'),
  "M-25": require('../assets/photos/Main/M-25.jpg'),
  "M-26": require('../assets/photos/Main/M-26.jpg'),
  "M-27": require('../assets/photos/Main/M-27.jpg'),
  "M-28": require('../assets/photos/Main/M-28.jpg'),
  "M-29": require('../assets/photos/Main/M-29.jpg'),
  "M-30": require('../assets/photos/Main/M-30.jpg'),
  "M-31": require('../assets/photos/Main/M-31.jpg'),
  "M-32": require('../assets/photos/Main/M-32.jpg'),
  "M-33": require('../assets/photos/Main/M-33.jpg'),
  "M-34": require('../assets/photos/Main/M-34.jpg'),
  "M-35": require('../assets/photos/Main/M-35.jpg'),
  "M-36": require('../assets/photos/Main/M-36.jpg'),
};

const getCloseImagePath = number => images[`C-${number}`];
const getMainImagePath = number => images[`M-${number}`];

const STRUCTURES_STORAGE_KEY = 'STRUCTURES_STORAGE_KEY';
const VISIT_COUNTER_KEY = 'VISIT_COUNTER_KEY';
const LAST_VISIT_DATE_KEY = 'LAST_VISIT_DATE_KEY';
const DAYS_VISITED_KEY = 'DAYS_VISITED_KEY';

export const StructureProvider = ({ children }) => {
    const [structures, setStructures] = useState([]);
    const [visitCounter, setVisitCounter] = useState(0);
    const [lastVisitDate, setLastVisitDate] = useState(null);
    const [daysVisited, setDaysVisited] = useState(0);

    const loadData = async () => {
        try {
            const [storedStructures, storedVisitCounter, storedLastVisitDate, storedDaysVisited] = await Promise.all([
                AsyncStorage.getItem(STRUCTURES_STORAGE_KEY),
                AsyncStorage.getItem(VISIT_COUNTER_KEY),
                AsyncStorage.getItem(LAST_VISIT_DATE_KEY),
                AsyncStorage.getItem(DAYS_VISITED_KEY)
            ]);

            if (storedStructures !== null) {
                setStructures(JSON.parse(storedStructures));
            } else {
                const initializedStructures = rawStructureData.map(s => ({
                    ...s,
                    closeUpImage: getCloseImagePath(s.number),
                    mainImage: getMainImagePath(s.number),
                    isVisited: false,
                    isOpened: false,
                    recentlyVisited: -1
                }));
                setStructures(initializedStructures);
            }

            setVisitCounter(storedVisitCounter !== null ? parseInt(storedVisitCounter) : 0);
            setLastVisitDate(storedLastVisitDate !== null ? new Date(storedLastVisitDate) : null);
            setDaysVisited(storedDaysVisited !== null ? parseInt(storedDaysVisited) : 0);
        } catch (error) {
            console.error('Failed to load data', error);
        }
    };

    const saveData = async () => {
        try {
            await Promise.all([
                AsyncStorage.setItem(STRUCTURES_STORAGE_KEY, JSON.stringify(structures)),
                AsyncStorage.setItem(VISIT_COUNTER_KEY, visitCounter.toString()),
                AsyncStorage.setItem(LAST_VISIT_DATE_KEY, lastVisitDate ? lastVisitDate.toISOString() : ''),
                AsyncStorage.setItem(DAYS_VISITED_KEY, daysVisited.toString())
            ]);
        } catch (error) {
            console.error('Failed to save data', error);
        }
    };

    useEffect(() => {
        loadData();
    }, []);

    useEffect(() => {
        saveData();
    }, [structures, visitCounter, lastVisitDate, daysVisited]);

    const markStructureAsVisited = (landmarkId) => {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        setVisitCounter(prev => prev + 1);

        if (!lastVisitDate || lastVisitDate < today) {
            setLastVisitDate(today);
            setDaysVisited(prev => prev + 1);
        }

        setStructures(prevStructures => {
            const updatedStructures = prevStructures.map(structure => 
                structure.number === landmarkId 
                    ? { ...structure, isVisited: true, recentlyVisited: visitCounter + 1 }
                    : structure
            );
            
            // Check if all structures are now visited
            if (updatedStructures.every(s => s.isVisited)) {
                // This could be a place to increment a "all visited" counter if needed
            }

            return updatedStructures;
        });

        return structures.find(s => s.number === landmarkId);
    };

    const resetVisitedStructures = () => {
        setStructures(prevStructures => prevStructures.map(structure => ({
            ...structure,
            isVisited: false,
            isOpened: false,
            recentlyVisited: -1
        })));
        setVisitCounter(0);
        setLastVisitDate(null);
        setDaysVisited(0);
    };

    const setAllStructuresAsVisited = () => {
        setStructures(prevStructures => prevStructures.map(structure => ({
            ...structure,
            isVisited: true
        })));
    };

    return (
        <StructureContext.Provider value={{ 
            structures, 
            setStructures, 
            resetVisitedStructures, 
            setAllStructuresAsVisited,
            markStructureAsVisited,
            visitCounter,
            daysVisited
        }}>
            {children}
        </StructureContext.Provider>
    );
};