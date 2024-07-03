// StructureData.js
import React, { createContext, useState, useContext, useEffect } from 'react';
import rawStructureData from './structures.json'; // Ensure this path is correct

const StructureContext = createContext();

export const useStructures = () => useContext(StructureContext);

export const StructureProvider = ({ children }) => {
    const [structures, setStructures] = useState([]);

    useEffect(() => {
        // Load and initialize structures with default values
        const initializedStructures = rawStructureData.map(s => ({
            ...s,
            imageName: `${s.number}M`,
            closeUp: `${s.number}C`,
            isVisited: false,
            isOpened: false,
            recentlyVisited: -1
        }));
        setStructures(initializedStructures);
    }, []);

    const resetVisitedStructures = () => {
        const updatedStructures = structures.map(structure => ({
            ...structure,
            isVisited: false,
            isOpened: false,
            recentlyVisited: -1
        }));
        setStructures(updatedStructures);
    };

    const setAllStructuresAsVisited = () => {
        const visitedStructures = structures.map(structure => ({
            ...structure,
            isVisited: true
        }));
        setStructures(visitedStructures);
    };

    return (
        <StructureContext.Provider value={{ structures, resetVisitedStructures, setAllStructuresAsVisited }}>
            {children}
        </StructureContext.Provider>
    );
};
