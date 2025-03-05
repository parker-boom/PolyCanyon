import SwiftUI

struct VisitNotificationView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        if let structure = dataStore.lastVisitedStructure {
            VisitNotificationContent(structure: structure)
        } else if let ghostStructure = dataStore.lastVisitedGhostStructure {
            // Convert ghost structure to a display structure
            let displayStructure = dataStore.ghostStructureToDisplayStructure(ghostStructure)
            VisitNotificationContent(structure: displayStructure, isGhostStructure: true)
        }
    }
}

struct VisitNotificationContent: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    let structure: Structure
    let isGhostStructure: Bool
    private let containerWidth: CGFloat = UIScreen.main.bounds.width - 80 // 40 padding on each side
    
    init(structure: Structure, isGhostStructure: Bool = false) {
        self.structure = structure
        self.isGhostStructure = isGhostStructure
    }
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    dataStore.dismissLastVisitedStructure()
                }
            
            // Main Container
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 12) {
                    // "Just Visited!" container
                    HStack { 
                        Spacer()
                        HStack(spacing: 8) {
                            // Different icon for ghost structures
                            Text(isGhostStructure ? "👻" : "🔥")
                                .font(.system(size: 30))
                                .padding(.top, -2) 
                            Text(isGhostStructure ? "Ghost Structure!" : "Just Visited!")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color.black.opacity(0.8))
                                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        Spacer()
                    }
                    .glassyBackground()
                    
                    // Image container
                    Image(structure.images[0])
                        .resizable()
                        .scaledToFill()
                        .frame(width: containerWidth - 40, height: 250)
                        .clipped()
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.65), radius: 10, x: 0, y: 4)
                        .overlay(
                            Text(isGhostStructure ? "HISTORICAL" : "#\(structure.number)")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.8))
                                )
                                .padding(8),
                            alignment: .bottomTrailing
                        )

                    // Progress Bar container
                    HStack {
                        Spacer()
                        ProgressBar(width: containerWidth - 40)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Material.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "FF8C00").opacity(0.1),
                                                Color(hex: "FFD700").opacity(0.05)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.5),
                                                .white.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5
                                    )
                            )
                    )
                    
                    // Learn More button
                    Button(action: {
                        if isGhostStructure {
                            // For ghost structures, we'll implement this in Phase 2
                            appState.activeFullScreenView = .ghostStructInfo
                            appState.ghostStructInfoNum = Int(structure.number) ?? 0
                        } else {
                            // Regular structure
                            appState.activeFullScreenView = .structInfo
                            appState.structInfoNum = structure.id
                        }
                        dataStore.dismissLastVisitedStructure()
                    }) {
                        HStack {
                            Spacer() 
                            Text("Learn More")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color.black.opacity(0.8))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color.black.opacity(0.6))
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                    }
                    .glassyBackground()
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
                .padding(.top, 25) // Reduced top padding to account for close button
                .padding(.horizontal, 20)
                
                // Close button
                Button(action: {
                    dataStore.dismissLastVisitedStructure()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.black.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Material.ultraThinMaterial))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
                }
                .offset(x: 10, y: -10)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Material.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.9), Color.white.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
            )
            .frame(maxWidth: containerWidth)
            .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
            .padding(.horizontal, 40)
            .transition(.scale)
            .animation(.easeInOut(duration: 0.3), value: dataStore.lastVisitedStructure)
        }
    }
}

struct GlassyBackground: ViewModifier {
    @EnvironmentObject var appState: AppState
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Material.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.5),
                                        .white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
            )
    }
}

extension View {
    func glassyBackground() -> some View {
        modifier(GlassyBackground())
    }
}

struct VisitNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let dataStore = DataStore.shared // Replace with your actual shared instance
        
        // Create a mock structure for preview and set it as lastVisitedStructure
        dataStore.markStructureAsVisited(1) // This will set lastVisitedStructure
        
        return Group {
            // Light Mode Preview
            VisitNotificationView()
                .environmentObject(appState)
                .environmentObject(dataStore)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Light Mode")
            
            // Dark Mode Preview
            VisitNotificationView()
                .environmentObject(appState)
                .environmentObject(dataStore)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Dark Mode")
        }
    }
}

extension Structure {
    init(
        number: Int,
        title: String,
        year: String,
        advisors: [String],
        builders: [String],
        description: String,
        funFact: String?,
        images: [String],
        isVisited: Bool = false,
        isOpened: Bool = false,
        recentlyVisited: Int = -1,
        isLiked: Bool = false
    ) {
        self.number = number
        self.title = title
        self.year = year
        self.advisors = advisors
        self.builders = builders
        self.description = description
        self.funFact = funFact
        self.images = images
        self.isVisited = isVisited
        self.isOpened = isOpened
        self.recentlyVisited = recentlyVisited
        self.isLiked = isLiked
    }
}
