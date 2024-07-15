import React, { useState, useEffect } from 'react';
import mapPointsData from './mapPoints.json';

// Define the structure of a map point
const mapPointSchema = {
  x: Number,
  y: Number,
  latitude: Number,
  longitude: Number,
  landmark: Number,
  number: Number
};

// Component to load and manage map points
const MapPoint = () => {
  const [mapPoints, setMapPoints] = useState([]);

  useEffect(() => {
    // Load map points from the JSON file and process data
    const processedData = mapPointsData.map(point => ({
      ...point,
      landmark: point.landmark === null ? -1 : point.landmark
    }));
    setMapPoints(processedData);
  }, []);

  return (
    <div>
      {/* Example rendering of map points */}
      {mapPoints.map((point, index) => (
        <div key={index}>
          <p>Point {index + 1}:</p>
          <p>Pixel Position: ({point.x}, {point.y})</p>
          <p>Coordinates: ({point.latitude}, {point.longitude})</p>
          <p>Landmark: {point.landmark}</p>
          <p>Number: {point.number}</p>
        </div>
      ))}
    </div>
  );
};

export default MapPoint;
