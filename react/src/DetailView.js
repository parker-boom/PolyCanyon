// DetailView.js
import React, { useState } from 'react';
import { View, Text, FlatList, Image, StyleSheet, TextInput, TouchableOpacity } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';  
import { useStructures } from './StructureData';
import FastImage from 'react-native-fast-image';

const DetailView = () => {
    const { structures } = useStructures();
    const [searchText, setSearchText] = useState('');
    const [isListView, setIsListView] = useState(true);  // Toggle state for list/grid view

    const filteredStructures = structures.filter(structure => {
        const searchLower = searchText.toLowerCase();
        return structure.title.toLowerCase().includes(searchLower) || 
               structure.number.toString().includes(searchLower);
    });

    const renderListItem = ({ item }) => (
        <View style={styles.row}>
            <Text style={styles.number}>{item.number}</Text>
            <Text style={styles.title}>{item.title}</Text>
            <View style={[styles.statusIndicator, item.isVisited ? styles.visited : styles.notVisited]} />
        </View>
    );

    const renderGridItem = ({ item }) => (
        <View style={styles.gridItem}>
            <FastImage 
                source={item.mainImage} 
                style={[styles.gridImage, item.isVisited ? styles.gridImageVisited : styles.gridImageNotVisited]}
                resizeMode={FastImage.resizeMode.cover} 
            />
            <View style={styles.gridInfoContainer}>
                <Text style={styles.gridNumber}>{item.number}</Text>
                <Text style={styles.gridTitle}>{item.title}</Text>
            </View>
        </View>
    );

    return (
        <View style={styles.container}>
            <View style={styles.searchContainer}>
                <TextInput
                    style={styles.searchBar}
                    placeholder="Search by number or title..."
                    value={searchText}
                    onChangeText={setSearchText}
                    autoCapitalize="none"
                    autoCorrect={false}
                />
                <TouchableOpacity onPress={() => setIsListView(!isListView)} style={styles.toggleButton}>
                    <Ionicons name={isListView ? "grid-outline" : "list"} size={24} color="black" />
                </TouchableOpacity>
            </View>
            {isListView ? (
                <FlatList
                    style={styles.list}
                    data={filteredStructures}
                    renderItem={renderListItem}
                    keyExtractor={item => item.number.toString()}
                    key={'list'}
                />
            ) : (
                <FlatList
                    data={filteredStructures}
                    renderItem={renderGridItem}
                    keyExtractor={item => item.number.toString()}
                    numColumns={2}
                    key={'grid'}
                />
            )}
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: 'white',
    },
    searchContainer: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: 10,
    },
    searchBar: {
        flex: 1,
        fontSize: 18,
        borderColor: 'gray',
        borderWidth: 1,
        padding: 10,
        borderRadius: 5,
        marginRight: 10,
        backgroundColor: 'white',
    },
    toggleButton: {
        padding: 10,
    },
    list: {
        backgroundColor: 'white',
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
    number: {
        fontSize: 18,
        width: 30,
        textAlign: 'center',
    },
    title: {
        fontSize: 23,
        fontWeight: 'bold',
        marginLeft: 10,
        flex: 1,
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
        height: 150, // Fixed height for each item
        backgroundColor: 'white',
        borderRadius: 15,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 6,
    },
    gridImage: {
        width: '100%',
        height: '100%',
        borderRadius: 15,
    },
    gridImageVisited: {
        filter: 'none', // No filter for visited
    },
    gridImageNotVisited: {
        filter: 'blur(3px)', // Blur effect for not visited
    },
    gridInfoContainer: {
        position: 'absolute',
        bottom: 0,
        left: 0,
        right: 0,
        backgroundColor: 'rgba(255, 255, 255, 0.8)',
        paddingVertical: 5,
        paddingHorizontal: 10,
        borderBottomLeftRadius: 15,
        borderBottomRightRadius: 15,
    },
    gridNumber: {
        fontSize: 18,
        color: 'black',
    },
    gridTitle: {
        fontSize: 16,
        color: 'black',
    },
});

export default DetailView;
