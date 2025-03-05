// metro.config.js
const { getDefaultConfig, mergeConfig } = require("@react-native/metro-config");
const path = require("path");

const config = {
  projectRoot: path.resolve(__dirname),
  watchFolders: [path.resolve(__dirname, "..", "assets")],
  resolver: {
    assetExts: ["jpg", "png", "jpeg", "svg", "gif", "webp"],
    extraNodeModules: new Proxy(
      {},
      {
        get: (target, name) => {
          if (name === "assets") {
            return path.resolve(__dirname, "..", "assets");
          }
          return path.join(__dirname, `node_modules/${name}`);
        },
      }
    ),
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
