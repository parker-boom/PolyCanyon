import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
} from "react-native";
import Ionicons from "react-native-vector-icons/Ionicons";

const DVRules = ({ userRole, setUserRole }) => {
  const [isStructureExpanded, setIsStructureExpanded] = useState(true);
  const [isSafetyExpanded, setIsSafetyExpanded] = useState(true);
  const [isRequirementsExpanded, setIsRequirementsExpanded] = useState(true);
  const [isVisitorRulesExpanded, setIsVisitorRulesExpanded] = useState(true);

  const CompetitorContent = () => {
    return (
      <>
        <View style={styles.tldrContainer}>
          <Text style={styles.tldrIcon}>🏗️</Text>
          <Text style={styles.tldrTitle}>TLDR: The Essentials</Text>
          <Text style={styles.tldrText}>
            Build a creative, portable shelter that's safe and stable. Follow
            site rules, submit required documentation, and stay with your
            structure overnight. Safety violations or misconduct lead to
            disqualification.
          </Text>
        </View>

        <View style={styles.sectionContainer}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>Structure Guidelines</Text>
            <TouchableOpacity
              onPress={() => setIsStructureExpanded(!isStructureExpanded)}
            >
              <Ionicons
                name="chevron-down"
                size={18}
                color="black"
                style={{
                  transform: [
                    { rotate: isStructureExpanded ? "-180deg" : "0deg" },
                  ],
                }}
              />
            </TouchableOpacity>
          </View>
          {isStructureExpanded && (
            <View style={styles.sectionContent}>
              <Text style={styles.bulletPoint}>
                • Deliver a well-crafted, stable shelter for the entire event
                weekend
              </Text>
              <Text style={styles.bulletPoint}>
                • Structures must be easily assembled and portable
              </Text>
              <Text style={styles.bulletPoint}>
                • Parts must fit within half of the 20' roadway width
              </Text>
              <Text style={styles.bulletPoint}>
                • Emphasize creativity and originality in design
              </Text>
              <Text style={styles.bulletPoint}>
                • No alteration or excavation of the site (minor adjustments
                allowed)
              </Text>
            </View>
          )}
        </View>

        <View style={styles.sectionContainer}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>Documentation & Presence</Text>
            <TouchableOpacity
              onPress={() => setIsRequirementsExpanded(!isRequirementsExpanded)}
            >
              <Ionicons
                name="chevron-down"
                size={18}
                color="black"
                style={{
                  transform: [
                    { rotate: isRequirementsExpanded ? "-180deg" : "0deg" },
                  ],
                }}
              />
            </TouchableOpacity>
          </View>
          {isRequirementsExpanded && (
            <View style={styles.sectionContent}>
              <Text style={styles.subheader}>Poster Requirements:</Text>
              <Text style={styles.bulletPoint}>
                • Competitor names and home college
              </Text>
              <Text style={styles.bulletPoint}>
                • Group name and faculty advisor (if applicable)
              </Text>
              <Text style={styles.bulletPoint}>
                • Optional: concept statement and technical drawings
              </Text>
              <Text style={styles.divider}></Text>
              <Text style={styles.bulletPoint}>
                • Must be present at designated call times
              </Text>
              <Text style={styles.bulletPoint}>
                • Return by 10:00 PM to sleep in structure
              </Text>
            </View>
          )}
        </View>

        <View style={styles.sectionContainer}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>Safety & Conduct</Text>
            <TouchableOpacity
              onPress={() => setIsSafetyExpanded(!setIsSafetyExpanded)}
            >
              <Ionicons
                name="chevron-down"
                size={18}
                color="black"
                style={{
                  transform: [
                    { rotate: isSafetyExpanded ? "-180deg" : "0deg" },
                  ],
                }}
              />
            </TouchableOpacity>
          </View>
          {isSafetyExpanded && (
            <View style={styles.sectionContent}>
              <Text style={styles.warningText}>
                Disqualification will result from:
              </Text>
              <Text style={styles.bulletPoint}>
                • Using unaltered pre-manufactured structures
              </Text>
              <Text style={styles.bulletPoint}>
                • Possession of fire-risk items or prohibited equipment
              </Text>
              <Text style={styles.bulletPoint}>
                • Possession of drugs, alcohol, or weapons
              </Text>
              <Text style={styles.bulletPoint}>
                • Actions endangering others or damaging structures
              </Text>
              <Text style={styles.bulletPoint}>
                • Interfering with other teams' participation
              </Text>
            </View>
          )}
        </View>
      </>
    );
  };

  const VisitorContent = () => {
    return (
      <>
        <View style={styles.tldrContainer}>
          <Text style={styles.tldrIcon}>👥</Text>
          <Text style={styles.tldrTitle}>TLDR: Visitor Guidelines</Text>
          <Text style={styles.tldrText}>
            Enjoy exploring Design Village while respecting the event space and
            competitors. Follow staff instructions, maintain safe distances, and
            avoid prohibited items to ensure everyone's safety and success.
          </Text>
        </View>

        <View style={styles.sectionContainer}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>Event Guidelines</Text>
            <TouchableOpacity
              onPress={() => setIsVisitorRulesExpanded(!isVisitorRulesExpanded)}
            >
              <Ionicons
                name="chevron-down"
                size={18}
                color="black"
                style={{
                  transform: [
                    { rotate: isVisitorRulesExpanded ? "-180deg" : "0deg" },
                  ],
                }}
              />
            </TouchableOpacity>
          </View>
          {isVisitorRulesExpanded && (
            <View style={styles.sectionContent}>
              <Text style={styles.bulletPoint}>
                • Follow all event staff instructions and stay within designated
                areas
              </Text>
              <Text style={styles.bulletPoint}>
                • Do not bring or use prohibited items (e.g., fire risks, drugs,
                alcohol, or weapons)
              </Text>
              <Text style={styles.bulletPoint}>
                • Respect competitor spaces—avoid interfering with structures or
                their assembly
              </Text>
              <Text style={styles.bulletPoint}>
                • Maintain a safe distance to ensure everyone's safety
              </Text>
            </View>
          )}
        </View>
      </>
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.roleSelector}>
        <TouchableOpacity
          style={[
            styles.roleButton,
            userRole === "competitor" && styles.roleButtonSelected,
          ]}
          onPress={() => setUserRole("competitor")}
        >
          <Text
            style={[
              styles.roleButtonText,
              userRole === "competitor" && styles.roleButtonTextSelected,
            ]}
          >
            Competitor
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[
            styles.roleButton,
            userRole === "visitor" && styles.roleButtonSelected,
          ]}
          onPress={() => setUserRole("visitor")}
        >
          <Text
            style={[
              styles.roleButtonText,
              userRole === "visitor" && styles.roleButtonTextSelected,
            ]}
          >
            Visitor
          </Text>
        </TouchableOpacity>
      </View>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
      >
        {userRole === "competitor" ? <CompetitorContent /> : <VisitorContent />}
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fafafa",
  },
  roleSelector: {
    flexDirection: "row",
    padding: 15,
    justifyContent: "center",
    gap: 10,
    backgroundColor: "white",
    borderBottomWidth: 1,
    borderBottomColor: "rgba(0,0,0,0.1)",
  },
  roleButton: {
    paddingVertical: 8,
    paddingHorizontal: 20,
    borderRadius: 20,
    backgroundColor: "rgba(0,0,0,0.05)",
    minWidth: 120,
    alignItems: "center",
  },
  roleButtonSelected: {
    backgroundColor: "#000",
  },
  roleButtonText: {
    fontSize: 16,
    fontWeight: "600",
    color: "#000",
  },
  roleButtonTextSelected: {
    color: "#fff",
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingTop: 15,
    paddingBottom: 40,
    paddingHorizontal: 24,
  },
  tldrContainer: {
    backgroundColor: "white",
    borderRadius: 16,
    padding: 20,
    marginBottom: 24,
    alignItems: "center",
    shadowColor: "#000",
    shadowOpacity: 0.05,
    shadowRadius: 10,
    shadowOffset: { width: 0, height: 4 },
    elevation: 3,
  },
  tldrIcon: {
    fontSize: 40,
    marginBottom: 10,
  },
  tldrTitle: {
    fontSize: 24,
    fontWeight: "bold",
    marginBottom: 10,
    color: "black",
  },
  tldrText: {
    fontSize: 16,
    color: "rgba(0,0,0,0.8)",
    textAlign: "center",
    lineHeight: 22,
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
  sectionContent: {
    paddingHorizontal: 4,
  },
  subheader: {
    fontSize: 18,
    fontWeight: "600",
    color: "black",
    marginBottom: 8,
  },
  bulletPoint: {
    fontSize: 16,
    color: "rgba(0,0,0,0.8)",
    marginBottom: 12,
    lineHeight: 22,
  },
  divider: {
    height: 1,
    backgroundColor: "rgba(0,0,0,0.1)",
    marginVertical: 12,
  },
  warningText: {
    fontSize: 18,
    fontWeight: "600",
    color: "#D32F2F",
    marginBottom: 12,
  },
});

export default DVRules;
