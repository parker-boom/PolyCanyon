// Enum for sorting structures
export const SortState = {
  ALL: 'all',
  FAVORITES: 'favorites',
  VISITED: 'visited'
};

// Structure model representing architectural structures
export class Structure {
  // Static properties (from JSON)
  number;
  title;
  year;
  advisors;
  builders;
  description;
  funFact;
  images;

  // Dynamic properties (user data)
  isVisited;
  isOpened;
  recentlyVisited;
  isLiked;

  constructor(data) {
    // Parse static properties
    this.number = data.Number;
    this.title = data.Name;
    this.year = data.Year;
    this.advisors = data.Advisors;
    this.builders = data.Builders;
    this.description = data.Description;
    this.funFact = data["Fun Fact"];
    this.images = data.Images;

    // Set dynamic properties with defaults
    this.isVisited = data.isVisited || false;
    this.isOpened = data.isOpened || false;
    this.recentlyVisited = data.recentlyVisited || -1;
    this.isLiked = data.isLiked || false;
  }

  // Unique identifier
  get id() {
    return this.number;
  }

  // Create a serializable object for storage
  toJSON() {
    return {
      // Only include dynamic properties that need to be persisted
      isVisited: this.isVisited,
      isOpened: this.isOpened,
      recentlyVisited: this.recentlyVisited,
      isLiked: this.isLiked
    };
  }
}

// Not implemented yet
/*
// Ghost structure model for special locations
export class GhostStructure {
  // Static properties
  number;
  name;
  year;
  advisors;
  builders;
  description;
  images;

  // Dynamic property
  isVisited;

  constructor(data) {
    this.number = parseInt(data.Number);
    this.name = data.Name;
    this.year = data.Year;
    this.advisors = data.Advisors;
    this.builders = data.Builders;
    this.description = data.Description;
    this.images = data.Images;
    
    this.isVisited = data.isVisited || false;
  }

  get id() {
    return this.number;
  }

  toJSON() {
    return {
      isVisited: this.isVisited
    };
  }
} */

// Map point model for locations
export class MapPoint {
  coordinate;
  pixelPosition;
  structure;

  constructor(data) {
    this.coordinate = {
      latitude: data.latitude,
      longitude: data.longitude
    };
    this.pixelPosition = {
      x: data.pixelX,
      y: data.pixelY
    };
    this.structure = data.structure;
  }

  // Helper method to create from raw JSON data
  static fromMapPointData(data) {
    return new MapPoint({
      latitude: data.latitude,
      longitude: data.longitude,
      pixelX: data.pixelX,
      pixelY: data.pixelY,
      structure: data.structure
    });
  }
}
