import React from 'react';
import { SafeAreaView, StyleSheet } from 'react-native';
import ContentView from './src/ContentView';

const App = () => {
  return (
    <SafeAreaView style={styles.container}>
      <ContentView />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default App;
