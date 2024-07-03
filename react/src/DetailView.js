// DetailView.js
import React from 'react';
import { View, Text, FlatList, StyleSheet } from 'react-native';
import { useStructures } from './StructureData';

const DetailView = () => {
    const { structures } = useStructures();

    const renderItem = ({ item }) => (
        <View style={styles.row}>
            <Text style={styles.number}>{item.number}</Text>
            <Text style={styles.title}>{item.title}</Text>
            <View style={[styles.statusIndicator, item.isVisited ? styles.visited : styles.notVisited]} />
        </View>
    );

    return (
        <FlatList
            data={structures}
            renderItem={renderItem}
            keyExtractor={item => item.number.toString()} // Ensure each item has a unique key
        />
    );
};

const styles = StyleSheet.create({
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
});

export default DetailView;
