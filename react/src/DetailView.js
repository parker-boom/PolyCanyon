import React, { useState, useEffect } from 'react';
import { View, Text, Button, ScrollView, StyleSheet } from 'react-native';
import Papa from 'papaparse';

const DetailView = () => {
  const [structures, setStructures] = useState([]);
  const [isGridView, setIsGridView] = useState(true);

  const loadCSV = () => {
    Papa.parse('file:///C:/Users/parke/Desktop/PolyCanyon/assets/data/structures.csv', {
      download: true,
      header: true,
      complete: (results) => {
        setStructures(results.data);
      },
      error: (error) => {
        console.error('Error loading CSV:', error);
      }
    });
  };

  useEffect(() => {
    loadCSV();
  }, []);

  return (
    <View style={styles.detailView}>
      <View style={styles.searchBarPlaceholder}></View>
      <Button title="Toggle View" onPress={() => setIsGridView(!isGridView)} />
      <ScrollView style={styles.listView}>
        {structures.map((structure, index) => (
          <View key={index} style={styles.structureItem}>
            <Text>{structure.number} - {structure.title}</Text>
          </View>
        ))}
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  detailView: {
    flex: 1,
    padding: 20,
    backgroundColor: 'lightseagreen',
  },
  searchBarPlaceholder: {
    width: '100%',
    height: 40,
    backgroundColor: '#f0f0f0',
    marginBottom: 20,
  },
  listView: {
    flex: 1,
    marginTop: 20,
  },
  structureItem: {
    padding: 10,
    backgroundColor: '#e9e9e9',
    borderBottomWidth: 1,
    borderBottomColor: '#ccc',
  },
});

export default DetailView;
