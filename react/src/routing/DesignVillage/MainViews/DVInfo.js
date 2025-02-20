// DVInfo.js
import React, { useState, useEffect, useRef } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Image,
  Dimensions,
} from "react-native";
import Ionicons from "react-native-vector-icons/Ionicons";

const { width } = Dimensions.get("window");

const DVInfo = () => {
  const [isWhatIsExpanded, setIsWhatIsExpanded] = useState(true);
  const [isGalleryExpanded, setIsGalleryExpanded] = useState(true);
  const [isHistoryExpanded, setIsHistoryExpanded] = useState(true);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [showFullHistory, setShowFullHistory] = useState(false);

  const images = [
    require("../Images/DV1.jpg"),
    require("../Images/DV2.jpg"),
    require("../Images/DV3.jpg"),
    require("../Images/DV4.jpg"),
    require("../Images/DV5.jpg"),
    require("../Images/DV6.jpg"),
  ];

  const scrollRef = useRef(null);

  useEffect(() => {
    const interval = setInterval(() => {
      const nextIndex = (currentImageIndex + 1) % images.length;
      setCurrentImageIndex(nextIndex);
      if (scrollRef.current) {
        scrollRef.current.scrollTo({
          x: nextIndex * (width - 48), // container width = screen width minus horizontal padding (24 * 2)
          animated: true,
        });
      }
    }, 5000);
    return () => clearInterval(interval);
  }, [currentImageIndex]);

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.contentContainer}>
        {renderWhatIsSection()}
        {renderImageCarousel()}
        {renderHistorySection()}
      </ScrollView>
    </View>
  );

  function renderWhatIsSection() {
    return (
      <View style={styles.sectionContainer}>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>What Is Design Village?</Text>
          <TouchableOpacity
            onPress={() => setIsWhatIsExpanded(!isWhatIsExpanded)}
          >
            <Ionicons
              name="chevron-down"
              size={18}
              color="black"
              style={{
                transform: [{ rotate: isWhatIsExpanded ? "-180deg" : "0deg" }],
              }}
            />
          </TouchableOpacity>
        </View>
        {isWhatIsExpanded && (
          <View style={styles.sectionContent}>
            <Text style={styles.bodyText}>
              Design Village is Cal Poly's signature hands-on design-build
              competition, where first-year architecture students and visiting
              college teams construct temporary shelters right here in Poly
              Canyon. Teams spend months designing their structures, carefully
              selecting materials, and planning the build. During the event,
              they'll construct their shelters on-site, live in them overnight,
              and later dismantle them— experiencing the full lifecycle of a
              construction project. Cal Poly students receive studio grades for
              their work, while visiting teams compete for awards based on
              innovation, sustainability, and craftsmanship.
            </Text>
            <Text
              style={[styles.bodyText, { marginTop: 8, fontWeight: "600" }]}
            >
              Theme: Nexus
            </Text>
          </View>
        )}
      </View>
    );
  }

  function renderImageCarousel() {
    return (
      <View style={styles.sectionContainer}>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Through The Years</Text>
          <TouchableOpacity
            onPress={() => setIsGalleryExpanded(!isGalleryExpanded)}
          >
            <Ionicons
              name="chevron-down"
              size={18}
              color="black"
              style={{
                transform: [{ rotate: isGalleryExpanded ? "-180deg" : "0deg" }],
              }}
            />
          </TouchableOpacity>
        </View>
        {isGalleryExpanded && (
          <ScrollView
            horizontal
            pagingEnabled
            showsHorizontalScrollIndicator={false}
            ref={scrollRef}
            style={styles.carousel}
          >
            {images.map((img, index) => (
              <Image
                key={index}
                source={img}
                style={styles.carouselImage}
                resizeMode="cover"
              />
            ))}
          </ScrollView>
        )}
      </View>
    );
  }

  function renderHistorySection() {
    return (
      <View style={styles.sectionContainer}>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>The History</Text>
          <TouchableOpacity
            onPress={() => setIsHistoryExpanded(!isHistoryExpanded)}
          >
            <Ionicons
              name="chevron-down"
              size={18}
              color="black"
              style={{
                transform: [{ rotate: isHistoryExpanded ? "-180deg" : "0deg" }],
              }}
            />
          </TouchableOpacity>
        </View>
        {isHistoryExpanded && (
          <View style={styles.sectionContent}>
            <Text style={styles.bodyText}>
              Design Village emerged from the early use of Poly Canyon as an
              experimental site for campus projects. Initially part of the
              broader Poly Royal open house activities in the early 1970s,
              students saw the canyon as the perfect place to test out
              temporary, buildable projects. By 1974, the first official Design
              Village took shape. Over time, the event evolved—with themed
              challenges and formal judging—into a key part of the Cal Poly
              experience, emphasizing practical, real-world construction skills.
            </Text>
            {showFullHistory && (
              <>
                <Text style={[styles.bodyText, { marginTop: 8 }]}>
                  By 1974, a group of students formally pitched and executed the
                  first Design Village, transforming the canyon into a live
                  construction site. Early projects were simple and
                  experimental, designed to be built quickly and then
                  dismantled, embodying the full lifecycle of a construction
                  project. As the event matured, formal judging categories and
                  themed challenges (from straightforward design contests to
                  more complex, conceptual themes) were introduced, reflecting
                  shifts in design practices and campus culture.
                </Text>
                <Text style={[styles.bodyText, { marginTop: 8 }]}>
                  Despite challenges along the way—such as periods of low
                  participation and issues with maintenance—the commitment to
                  hands-on learning never waned. Revitalization efforts in the
                  1990s and again in the 2000s have reinforced the importance of
                  Design Village as a practical training ground. Today, in its
                  50th anniversary, Design Village stands as a living tradition
                  that not only preserves the spirit of experimental learning in
                  Poly Canyon but also continues to prepare future architects
                  for the realities of construction, teamwork, and creative
                  problem-solving.
                </Text>
              </>
            )}
            <TouchableOpacity
              style={styles.learnMoreButton}
              onPress={() => setShowFullHistory(!showFullHistory)}
            >
              <Text style={styles.learnMoreButtonText}>
                {showFullHistory ? "Show Less" : "Learn More"}
              </Text>
            </TouchableOpacity>
          </View>
        )}
      </View>
    );
  }
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fafafa", // Similar to Color(white: 0.98)
  },
  contentContainer: {
    paddingTop: 15,
    paddingBottom: 40,
    paddingHorizontal: 24,
  },
  sectionContainer: {
    backgroundColor: "white",
    borderRadius: 16,
    padding: 16,
    marginBottom: 24,
    shadowColor: "#000",
    shadowOpacity: 0.05,
    shadowRadius: 10,
    shadowOffset: { width: 0, height: 4 },
    elevation: 3,
  },
  sectionHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: "bold",
    color: "black",
  },
  sectionContent: {},
  bodyText: {
    fontSize: 16,
    color: "rgba(0,0,0,0.8)",
    lineHeight: 22,
  },
  carousel: {
    height: 240,
    borderBottomLeftRadius: 16,
    borderBottomRightRadius: 16,
    overflow: "hidden",
  },
  carouselImage: {
    width: width - 48, // Accounts for horizontal padding (24 * 2)
    height: 240,
    marginRight: 8,
    borderBottomLeftRadius: 16,
    borderBottomRightRadius: 16,
  },
  learnMoreButton: {
    marginTop: 8,
    paddingVertical: 12,
    backgroundColor: "rgba(128,128,128,0.1)",
    borderRadius: 12,
    alignItems: "center",
  },
  learnMoreButtonText: {
    fontSize: 16,
    fontWeight: "600",
    color: "black",
  },
});

export default DVInfo;
