import SwiftUI

struct DVInfo: View {
    @State private var isHistoryExpanded = true
    @State private var isWhatIsExpanded = true
    @State private var isGalleryExpanded = true
    @State private var currentImageIndex = 0
    @State private var showFullHistory = false
    
    private let images = ["DV1", "DV2", "DV3", "DV4", "DV5", "DV6"]
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                whatIsSection
                imageCarousel
                historySection
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 40)
        }
    }
    
    private var whatIsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                DVTitleWithShadow(
                    text: "What Is Design Village?",
                    font: .system(size: 24, weight: .bold)
                )
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isWhatIsExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DVDesignSystem.Colors.text)
                        .rotationEffect(.degrees(isWhatIsExpanded ? -180 : 0))
                }
            }
            
            if isWhatIsExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Design Village is Cal Poly's signature hands-on design-build competition, where first-year architecture students and visiting college teams construct temporary shelters right here in Poly Canyon. Teams spend months designing their structures, carefully selecting materials, and planning the build. During the event, they'll construct their shelters on-site, live in them overnight, and later dismantle them—experiencing the full lifecycle of a construction project. Cal Poly students receive studio grades for their work, while visiting teams compete for awards based on innovation, sustainability, and craftsmanship.")
                        .font(.system(size: 16))
                        .foregroundColor(DVDesignSystem.Colors.textSecondary)
                        .lineSpacing(4)
                    
                    HStack {
                        Text("Theme:")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DVDesignSystem.Colors.text)
                        
                        Text("Nexus")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        DVDesignSystem.Colors.orange,
                                        DVDesignSystem.Colors.teal
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .padding(.top, 8)
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(DVDesignSystem.Components.card())
    }
    
    private var imageCarousel: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                DVTitleWithShadow(
                    text: "Through The Years",
                    font: .system(size: 24, weight: .bold)
                )
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isGalleryExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DVDesignSystem.Colors.text)
                        .rotationEffect(.degrees(isGalleryExpanded ? -180 : 0))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            
            if isGalleryExpanded {
                TabView(selection: $currentImageIndex) {
                    ForEach(0..<images.count, id: \.self) { index in
                        Image(images[index])
                            .resizable()
                            .scaledToFill()
                            .tag(index)
                    }
                }
                .frame(height: 240)
                .clipShape(
                    BottomRoundedRectangle(cornerRadius: 16)
                )
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .onReceive(timer) { _ in
                    withAnimation {
                        currentImageIndex = (currentImageIndex + 1) % images.count
                    }
                }
                .transition(.opacity)
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    DVDesignSystem.Colors.orange.opacity(0.7),
                                    DVDesignSystem.Colors.teal.opacity(0.7)
                                ],
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                        )
                        .blendMode(.overlay)
                )
            }
        }
        .background(DVDesignSystem.Components.card())
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                DVTitleWithShadow(
                    text: "The History",
                    font: .system(size: 24, weight: .bold)
                )
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isHistoryExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DVDesignSystem.Colors.text)
                        .rotationEffect(.degrees(isHistoryExpanded ? -180 : 0))
                }
            }
            
            if isHistoryExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Design Village emerged from the early use of Poly Canyon as an experimental site for campus projects. Initially part of the broader Poly Royal open house activities in the early 1970s, students saw the canyon as the perfect place to test out temporary, buildable projects. By 1974, the first official Design Village took shape. Over time, the event evolved—with themed challenges and formal judging—into a key part of the Cal Poly experience, emphasizing practical, real-world construction skills.")
                        .font(.system(size: 16))
                        .foregroundColor(DVDesignSystem.Colors.textSecondary)
                        .lineSpacing(4)
                    
                    if showFullHistory {
                        Text("By 1974, a group of students formally pitched and executed the first Design Village, transforming the canyon into a live construction site. Early projects were simple and experimental, designed to be built quickly and then dismantled, embodying the full lifecycle of a construction project. As the event matured, formal judging categories and themed challenges (from straightforward design contests to more complex, conceptual themes) were introduced, reflecting shifts in design practices and campus culture.")
                            .font(.system(size: 16))
                            .foregroundColor(DVDesignSystem.Colors.textSecondary)
                            .lineSpacing(4)
                            .padding(.top, 8)
                        
                        Text("Despite challenges along the way—such as periods of low participation and issues with maintenance—the commitment to hands-on learning never waned. Revitalization efforts in the 1990s and again in the 2000s have reinforced the importance of Design Village as a practical training ground. Today, in its 50th anniversary, Design Village stands as a living tradition that not only preserves the spirit of experimental learning in Poly Canyon but also continues to prepare future architects for the realities of construction, teamwork, and creative problem-solving.")
                            .font(.system(size: 16))
                            .foregroundColor(DVDesignSystem.Colors.textSecondary)
                            .lineSpacing(4)
                            .padding(.top, 8)
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showFullHistory.toggle()
                        }
                    } label: {
                        Text(showFullHistory ? "Show Less" : "Learn More")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DVDesignSystem.Colors.text)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(DVDesignSystem.Colors.yellow.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: [
                                                        DVDesignSystem.Colors.orange,
                                                        DVDesignSystem.Colors.teal
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                    }
                    .padding(.top, 8)
                    .pressAction {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            // Press effect
                        }
                    } onRelease: {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            // Release effect
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(DVDesignSystem.Components.card())
    }
}

struct DVInfo_Previews: PreviewProvider {
    static var previews: some View {
        DVInfo()
            .nexusStyle()
    }
}
