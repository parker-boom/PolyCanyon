import SwiftUI

struct DVRules: View {
    @Binding var userRole: DVRole
    @State private var isStructureExpanded = true
    @State private var isSafetyExpanded = true
    @State private var isRequirementsExpanded = true
    @State private var isVisitorRulesExpanded = true
    
    var body: some View {
        VStack(spacing: 0) {
            roleSelector

            ScrollView {
                rulesContent
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var roleSelector: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation {
                    userRole = .competitor
                }
            } label: {
                Text("Competitor")
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .frame(minWidth: 140)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(userRole == .competitor ? 
                                  DVDesignSystem.Colors.orange.opacity(0.8) : 
                                  DVDesignSystem.Colors.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                userRole == .competitor ?
                                DVDesignSystem.Colors.orange :
                                DVDesignSystem.Colors.divider,
                                lineWidth: 1.5
                            )
                    )
                    .foregroundColor(DVDesignSystem.Colors.text)
                    .shadow(color: DVDesignSystem.Colors.shadowColor, 
                            radius: userRole == .competitor ? 4 : 2, 
                            x: 0, y: 2)
            }
            .scaleEffect(userRole == .competitor ? 1.05 : 1.0)
            
            Button {
                withAnimation {
                    userRole = .visitor
                }
            } label: {
                Text("Visitor")
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .frame(minWidth: 140)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(userRole == .visitor ? 
                                  DVDesignSystem.Colors.teal.opacity(0.8) : 
                                  DVDesignSystem.Colors.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                userRole == .visitor ?
                                DVDesignSystem.Colors.teal :
                                DVDesignSystem.Colors.divider,
                                lineWidth: 1.5
                            )
                    )
                    .foregroundColor(DVDesignSystem.Colors.text)
                    .shadow(color: DVDesignSystem.Colors.shadowColor, 
                            radius: userRole == .visitor ? 4 : 2, 
                            x: 0, y: 2)
            }
            .scaleEffect(userRole == .visitor ? 1.05 : 1.0)
        }
        .padding(.vertical, 15)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: userRole)
    }
    
    private var rulesContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            if userRole == .competitor {
                competitorRules
            } else {
                visitorRules
            }
        }
    }
    
    private var competitorRules: some View {
        VStack(alignment: .leading, spacing: 24) {
            tldrSection(
                emoji: "🏗️",
                title: "TLDR: The Essentials",
                description: "Build a creative, portable shelter that's safe and stable. Follow site rules, submit required documentation, and stay with your structure overnight. Safety violations or misconduct lead to disqualification."
            )
            
            expandableSection(
                title: "Structure Guidelines",
                isExpanded: $isStructureExpanded,
                content: {
                    VStack(alignment: .leading, spacing: 12) {
                        bulletPoint("Deliver a well-crafted, stable shelter for the entire event weekend")
                        bulletPoint("Structures must be easily assembled and portable")
                        bulletPoint("Parts must fit within half of the 20' roadway width")
                        bulletPoint("Emphasize creativity and originality in design")
                        bulletPoint("No alteration or excavation of the site (minor adjustments allowed)")
                    }
                }
            )
            
            expandableSection(
                title: "Housekeeping",
                isExpanded: $isRequirementsExpanded,
                content: {
                    VStack(alignment: .leading, spacing: 12) {
                        DVTitleWithShadow(
                            text: "Poster Requirements:",
                            font: .system(size: 18, weight: .semibold)
                        )
                        .padding(.bottom, 4)
                        
                        bulletPoint("Competitor names and home college")
                        bulletPoint("Group name and faculty advisor (if applicable)")
                        bulletPoint("Optional: concept statement and technical drawings")
                        
                        Divider()
                            .background(DVDesignSystem.Colors.divider)
                            .padding(.vertical, 8)
                        
                        bulletPoint("Must be present at designated call times")
                        bulletPoint("Return by 10:00 PM to sleep in structure")
                    }
                }
            )
            
            expandableSection(
                title: "Safety & Conduct",
                isExpanded: $isSafetyExpanded,
                content: {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Disqualification will result from:")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DVDesignSystem.Colors.red)
                            .padding(.bottom, 4)
                        
                        bulletPoint("Using unaltered pre-manufactured structures")
                        bulletPoint("Possession of fire-risk items or prohibited equipment")
                        bulletPoint("Possession of drugs, alcohol, or weapons")
                        bulletPoint("Actions endangering others or damaging structures")
                        bulletPoint("Interfering with other teams' participation")
                    }
                }
            )
        }
    }
    
    private var visitorRules: some View {
        VStack(alignment: .leading, spacing: 24) {
            tldrSection(
                emoji: "👥",
                title: "TLDR: Visitor Guidelines",
                description: "Enjoy exploring Design Village while respecting the event space and competitors. Follow staff instructions, maintain safe distances, and avoid prohibited items to ensure everyone's safety and success."
            )
            
            expandableSection(
                title: "Event Guidelines",
                isExpanded: $isVisitorRulesExpanded,
                content: {
                    VStack(alignment: .leading, spacing: 12) {
                        bulletPoint("Follow all event staff instructions and stay within designated areas")
                        bulletPoint("Do not bring or use prohibited items (e.g., fire risks, drugs, alcohol, or weapons)")
                        bulletPoint("Respect competitor spaces—avoid interfering with structures or their assembly")
                        bulletPoint("Maintain a safe distance to ensure everyone's safety")
                    }
                }
            )
        }
    }
    
    private func tldrSection(emoji: String, title: String, description: String) -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text(emoji)
                .font(.system(size: 40))
            
            DVTitleWithShadow(
                text: title,
                font: .system(size: 24, weight: .bold)
            )
            .multilineTextAlignment(.center)
            
            Text(description)
                .font(.system(size: 16))
                .foregroundColor(DVDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(DVDesignSystem.Components.card())
    }
    
    private func expandableSection<Content: View>(
        title: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.wrappedValue.toggle()
                }
            } label: {
                HStack {
                    DVTitleWithShadow(
                        text: title,
                        font: .system(size: 24, weight: .bold)
                    )
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DVDesignSystem.Colors.text)
                        .rotationEffect(.degrees(isExpanded.wrappedValue ? -180 : 0))
                        .background(
                            Circle()
                                .fill(DVDesignSystem.Colors.yellow.opacity(0.3))
                                .frame(width: 32, height: 32)
                                .opacity(isExpanded.wrappedValue ? 1 : 0)
                        )
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded.wrappedValue {
                content()
                    .padding(.leading, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .background(DVDesignSystem.Components.card())
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(DVDesignSystem.Colors.yellow)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(DVDesignSystem.Colors.text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct DVRules_Previews: PreviewProvider {
    static var previews: some View {
        DVRules(userRole: .constant(.competitor))
            .nexusStyle()
    }
}
