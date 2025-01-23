import React from "react";
import { SafeAreaView, StyleSheet } from "react-native";
import AppView from "./src/AppView";

const App = () => {
  return (
    <SafeAreaView style={styles.container}>
      <AppView />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default App;
