// App.js
import React from "react";
import { SafeAreaView, StyleSheet } from "react-native";
import RootRouter from "./src/routing/RootRouter";

const App = () => {
  return (
    <SafeAreaView style={styles.container}>
      <RootRouter />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default App;
