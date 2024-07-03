import React, { useState } from 'react';
import { View, Text, FlatList, StyleSheet, TextInput } from 'react-native';
import { useStructures } from './StructureData';

const DetailView = () => {
    const { structures } = useStructures();
    const [searchText, setSearchText] = useState('');

    const filteredStructures = structures.filter(structure => {
        const searchLower = searchText.toLowerCase();
        return structure.title.toLowerCase().includes(searchLower) || 
               structure.number.toString().includes(searchLower);
    });

    const renderItem = ({ item }) => (
        <View style={styles.row}>
            <Text style={styles.number}>{item.number}</Text>
            <Text style={styles.title}>{item.title}</Text>
            <View style={[styles.statusIndicator, item.isVisited ? styles.visited : styles.notVisited]} />
        </View>
    );

    return (
        <View style={styles.container}>
            <TextInput
                style={styles.searchBar}
                placeholder="Search by number or title..."
                value={searchText}
                onChangeText={setSearchText}
                autoCapitalize="none"
                autoCorrect={false}
            />
            <FlatList
                style={styles.list}
                data={filteredStructures}
                renderItem={renderItem}
                keyExtractor={item => item.number.toString()}
            />
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: 'white',
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
    searchBar: {
        fontSize: 18,
        borderColor: 'gray',
        borderWidth: 1,
        padding: 10,
        margin: 10,
        borderRadius: 5,
        backgroundColor: 'white',
    },
});

export default DetailView;