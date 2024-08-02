// MARK: - DetailView Component
/**
 * DetailView Component
 * 
 * This component displays a list or grid of structures, allowing users to search,
 * filter, and view details of each structure. It supports both light and dark modes.
 * 
 * Features:
 * - Search functionality for structures
 * - Filtering options (All, Visited, Unvisited)
 * - Toggle between list and grid views
 * - Dark mode support
 * - Structure detail pop-up
 * 
 * The component uses various hooks for state management and integrates with
 * the DarkModeContext for consistent theming across the app.
 */

import React, { useState, useEffect } from 'react';
import { 
    View, 
    Text, 
    FlatList, 
    StyleSheet, 
    TextInput, 
    TouchableOpacity, 
    Animated, 
    Modal 
} from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';  
import { useStructures } from './StructureData';
import FastImage from 'react-native-fast-image';
import { BlurView } from '@react-native-community/blur';
import StructPopUp from './StructPopUp';
import { useDarkMode } from './DarkMode';

const DetailView = () => {
    // MARK: - Hooks and Context
    const { structures } = useStructures();
    const { isDarkMode } = useDarkMode();
    const [searchText, setSearchText] = useState('');
    const [isListView, setIsListView] = useState(false);
    const [filterState, setFilterState] = useState('all');
    const [popUpText, setPopUpText] = useState('');
    const popUpOpacity = useState(new Animated.Value(0))[0];
    const [selectedStructure, setSelectedStructure] = useState(null);

    // MARK: - Filtering Logic
    const filteredStructures = structures.filter(structure => {
        const searchLower = searchText.toLowerCase();
        const matchesSearch = structure.title.toLowerCase().includes(searchLower) || 
                             structure.number.toString().includes(searchLower);

        if (filterState === 'all') return matchesSearch;
        if (filterState === 'visited') return matchesSearch && structure.isVisited;
        if (filterState === 'unvisited') return matchesSearch && !structure.isVisited;
    });

    // MARK: - Event Handlers
    const handleFilterChange = () => {
        let newFilterState;
        let newPopUpText;

        if (filterState === 'all') {
            newFilterState = 'visited';
            newPopUpText = 'Visited';
        } else if (filterState === 'visited') {
            newFilterState = 'unvisited';
            newPopUpText = 'Unvisited';
        } else {
            newFilterState = 'all';
            newPopUpText = 'All';
        }

        setFilterState(newFilterState);
        setPopUpText(newPopUpText);

        Animated.sequence([
            Animated.timing(popUpOpacity, { toValue: 1, duration: 300, useNativeDriver: true }),
            Animated.timing(popUpOpacity, { toValue: 0, duration: 700, useNativeDriver: true, delay: 1000 })
        ]).start();
    };

    const handleStructurePress = (structure) => {
        setSelectedStructure(structure);
    };

    // MARK: - Render Functions
    const renderListItem = ({ item }) => (
        <TouchableOpacity onPress={() => handleStructurePress(item)}>
            <View style={[styles.row, isDarkMode && styles.darkRow]}>
                <Text style={[styles.number, isDarkMode && styles.darkText]}>{item.number}</Text>
                <Text style={[styles.title, isDarkMode && styles.darkText]}>{item.title}</Text>
                <View style={[styles.statusIndicator, item.isVisited ? styles.visited : styles.notVisited]} />
            </View>
        </TouchableOpacity>
    );

    const renderGridItem = ({ item }) => (
        <TouchableOpacity onPress={() => handleStructurePress(item)} style={[styles.gridItem, styles.shadow, isDarkMode && styles.darkGridItem]}>
            <View style={styles.imageContainer}>
                <FastImage 
                    source={item.mainImage} 
                    style={styles.gridImage}
                    resizeMode={FastImage.resizeMode.cover} 
                />
                {!item.isVisited && (
                    <BlurView
                        style={styles.blurView}
                        blurType={isDarkMode ? "dark" : "light"}
                        blurAmount={2}
                    />
                )}
            </View>
            <View style={[styles.gridInfoContainer, isDarkMode && styles.darkGridInfoContainer]}>
                <Text style={[styles.gridNumber, isDarkMode && styles.darkText]}>{item.number}</Text>
                <Text style={[styles.gridTitle, isDarkMode && styles.darkText]}>{item.title}</Text>
            </View>
        </TouchableOpacity>
    );

    // MARK: - Main Render
    return (
        <View style={[styles.container, isDarkMode && styles.darkContainer]}>
            <View style={styles.searchContainerWrapper}>
                <View style={[styles.searchContainer, isDarkMode && styles.darkSearchContainer]}>
                    <TouchableOpacity onPress={handleFilterChange} style={styles.filterButton}>
                        <Ionicons 
                            name="eye" 
                            size={32}
                            color={filterState === 'all' ? (isDarkMode ? 'white' : 'black') : filterState === 'visited' ? 'green' : 'red'} 
                        />
                    </TouchableOpacity>
                    <View style={styles.searchBarContainer}>
                        <TextInput
                            style={[styles.searchBar, isDarkMode && styles.darkSearchBar]}
                            placeholder="Search by number or title..."
                            placeholderTextColor={isDarkMode ? '#888' : '#666'}
                            value={searchText}
                            onChangeText={setSearchText}
                            autoCapitalize="none"
                            autoCorrect={false}
                        />
                        {searchText !== "" && (
                            <TouchableOpacity onPress={() => setSearchText("")} style={styles.clearButton}>
                                <Ionicons name="close-circle" size={20} color={isDarkMode ? 'white' : 'gray'} />
                            </TouchableOpacity>
                        )}
                    </View>
                    <TouchableOpacity onPress={() => setIsListView(!isListView)} style={styles.toggleButton}>
                        <Ionicons name={isListView ? "list-outline" : "grid-outline"} size={32} color={isDarkMode ? 'white' : 'black'} />
                    </TouchableOpacity>
                </View>
            </View>
            <FlatList
                style={[styles.list, isDarkMode && styles.darkList]}
                data={filteredStructures}
                renderItem={isListView ? renderListItem : renderGridItem}
                keyExtractor={item => item.number.toString()}
                key={isListView ? 'list' : 'grid'}
                numColumns={isListView ? 1 : 2}
            />
            <Animated.View style={[styles.popUp, { opacity: popUpOpacity }]}>
                <Text style={[styles.popUpText, isDarkMode && styles.darkPopUpText]}>{popUpText}</Text>
            </Animated.View>
            <Modal
                visible={selectedStructure !== null}
                transparent={true}
                animationType="fade"
                onRequestClose={() => setSelectedStructure(null)}
            >
                {selectedStructure && (
                    <StructPopUp
                        structure={selectedStructure}
                        onClose={() => setSelectedStructure(null)}
                        isDarkMode={isDarkMode}
                    />
                )}
            </Modal>
        </View>
    );
};

// MARK: - Styles
const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: 'white',
    },
    darkContainer: {
        backgroundColor: 'black',
    },
    searchContainerWrapper: {
        padding: 10,
        paddingBottom: 5,
    },
    searchContainer: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: 10,
        backgroundColor: 'white',
        borderRadius: 10,
        elevation: 25,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.95,
        shadowRadius: 13.84,
    },
    darkSearchContainer: {
        backgroundColor: '#2C2C2E',
    },
    searchBarContainer: {
        flex: 1,
        flexDirection: 'row',
        alignItems: 'center',
        marginHorizontal: 10,
    },
    searchBar: {
        flex: 1,
        fontSize: 18,
        color: 'black',
    },
    darkSearchBar: {
        color: 'white',
    },
    clearButton: {
        padding: 5,
    },
    filterButton: {
        padding: 5,
        width: 50,
        height: 50,
        justifyContent: 'center',
        alignItems: 'center',
        fontWeight: 'bold',
    },
    toggleButton: {
        padding: 5,
        width: 50,
        height: 50,
        justifyContent: 'center',
        alignItems: 'center',
        fontWeight: 'bold',
    },
    list: {
        backgroundColor: 'white',
    },
    darkList: {
        backgroundColor: 'black',
    },
    row: {
        flexDirection: 'row',
        padding: 15,
        backgroundColor: 'white',
        borderBottomWidth: 1,
        borderBottomColor: 'grey',
        alignItems: 'center',
        justifyContent: 'space-between',
    },
    darkRow: {
        backgroundColor: '#1C1C1E',
        borderBottomColor: '#2C2C2E',
    },
    number: {
        fontSize: 18,
        width: 30,
        textAlign: 'center',
        fontWeight: 'thin',
        color: 'black',
        opacity: 0.75,
    },
    title: {
        fontSize: 23,
        fontWeight: 'bold',
        marginLeft: 10,
        flex: 1,
        color: 'black',
    },
    darkText: {
        color: 'white',
    },
    statusIndicator: {
        width: 10,
        height: 10,
        borderRadius: 5,
        marginLeft: 10,
        marginRight: 10,
    },
    visited: {
        backgroundColor: 'green',
    },
    notVisited: {
        backgroundColor: 'red',
    },
    gridItem: {
        flex: 1,
        margin: 10,
        justifyContent: 'center',
        alignItems: 'center',
        height: 165, 
        backgroundColor: 'white',
        borderRadius: 15,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.95,
        shadowRadius: 3.84,
        elevation: 7.5,
    },
    darkGridItem: {
        backgroundColor: '#1C1C1E',
        shadowColor: '#FFF',
    },
    imageContainer: {
        width: '100%',
        height: '100%',
        borderRadius: 15,
        overflow: 'hidden',
    },
    gridImage: {
        width: '100%',
        height: '100%',
    },
    blurView: {
        position: 'absolute',
        top: 0,
        left: 0,
        bottom: 0,
        right: 0,
    },
    gridInfoContainer: {
        position: 'absolute',
        bottom: 0,
        left: 0,
        right: 0,
        backgroundColor: 'rgba(255, 255, 255, 0.85)', 
        paddingVertical: 5,
        paddingHorizontal: 10,
        borderBottomLeftRadius: 15,
        borderBottomRightRadius: 15,
    },
    darkGridInfoContainer: {
        backgroundColor: 'rgba(28, 28, 30, 0.85)',
    },
    gridNumber: {
        fontSize: 22,
        color: 'black',
        fontWeight: 'bold',
    },
    gridTitle: {
        fontSize: 18,
        color: 'black',
    },
    popUp: {
        position: 'absolute',
        bottom: 20,
        left: 0,
        right: 0,
        alignItems: 'center',
        justifyContent: 'center',
    },
    popUpText: {
        color: 'black',
        fontSize: 24,
        fontWeight: 'bold',
        textAlign: 'center',
        backgroundColor: 'white',
        paddingVertical: 12,
        paddingHorizontal: 24,
        borderRadius: 10,
        elevation: 5,
    },
    darkPopUpText: {
        color: 'white',
        backgroundColor: '#2C2C2E',
    },
});

export default DetailView;
