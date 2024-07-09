import React, { useState } from 'react';
import { View, Text, FlatList, StyleSheet, TextInput, TouchableOpacity } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';  
import { useStructures } from './StructureData';
import FastImage from 'react-native-fast-image';
import { BlurView } from '@react-native-community/blur';

const DetailView = () => {
    const { structures } = useStructures();
    const [searchText, setSearchText] = useState('');
    const [isListView, setIsListView] = useState(false);

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
        <View style={[styles.gridItem, styles.shadow]}>
            <View style={styles.imageContainer}>
                <FastImage 
                    source={item.mainImage} 
                    style={styles.gridImage}
                    resizeMode={FastImage.resizeMode.cover} 
                />
                {!item.isVisited && (
                    <BlurView
                        style={styles.blurView}
                        blurType="light"
                        blurAmount={2}
                    />
                )}
            </View>
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
                    <Ionicons name={isListView ? "grid-outline" : "list-outline"} size={24} color="black" />
                </TouchableOpacity>
            </View>
            <FlatList
                style={styles.list}
                data={filteredStructures}
                renderItem={isListView ? renderListItem : renderGridItem}
                keyExtractor={item => item.number.toString()}
                key={isListView ? 'list' : 'grid'}
                numColumns={isListView ? 1 : 2}
            />
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
        // CHANGE: Added shadow to every grid item
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.95,
        shadowRadius: 13.84,
        elevation: 15, // for Android
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
        backgroundColor: 'rgba(211, 211, 211, 0.6)', 
        paddingVertical: 5,
        paddingHorizontal: 10,
        borderBottomLeftRadius: 15,
        borderBottomRightRadius: 15,
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
});

export default DetailView;