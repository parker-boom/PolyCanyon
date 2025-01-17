import SwiftUI

struct VisitNotificationView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    let structure: Structure
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    dataStore.dismissLastVisitedStructure()
                }
            
            // Glassmorphic popup container
            VStack(spacing: 12) {  
                    // "Just Visited!" in a bold modern style with a proper container
                    HStack { 

                        Spacer()

                        HStack(spacing: 8) {
                            Text("🔥")
                                .font(.system(size: 30))
                                .padding(.top, -2) 
                            Text("Just Visited!")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(Color.black.opacity(0.8))
                                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                            
                        }
                        .padding(.vertical, 8)
                        .padding(.trailing, 12)
                        .padding(.leading, 10)

                        Spacer()
                    }
                    .glassyBackground()
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                
                
                // Image container
                ZStack(alignment: .bottomTrailing) {
                    Image(structure.images[0])
                        .resizable()
                        .scaledToFill() // Scale without stretching
                        .frame(width: 270, height: 250)
                        .clipped() // Ensure it fits the container
                        .cornerRadius(12)
                    
                    // Overlay for structure number
                    Text("#\(structure.number)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.8))
                        )
                        .padding(8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 0)
                
                HStack(spacing: 0) {
                    // Left section with the X button
                    Button(action: {
                        // Close the popup
                        dataStore.dismissLastVisitedStructure()
                    }) {
                        HStack {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.black.opacity(0.6))
                                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                        }
                        .frame(width: 60, height: 50) // Fixed size for the "X" button 
                    }
                    
                    // Divider line
                    Rectangle()
                        .fill(Color(white: 0.7))
                        .frame(width: 1)

                    // Right section with "Learn More >"
                    Button(action: {
                        // Open StructInfo for the current structure
                        appState.activeFullScreenView = .structInfo
                        appState.structInfoNum = structure.id
                        dataStore.dismissLastVisitedStructure()
                    }) {
                        HStack {
                            Text("Learn More")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color.black.opacity(0.6))
                                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color.black.opacity(0.6))
                                .padding(.leading, 15)
                                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                        }
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                }
                .frame(height: 50)
                .glassyBackground()
                .padding(.horizontal, 20)
                .padding(.bottom, 10)

            }
            .padding(10)
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
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 2)
            .shadow(color: .white.opacity(0.1), radius: 6, x: 0, y: 0)
            .frame(maxHeight: UIScreen.main.bounds.height * 0.5) 
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
        
        // Create a mock random structure for preview
        let randomStructure = dataStore.structures.randomElement() ?? Structure(
            number: 42,
            title: "Poly Canyon Experimental House",
            year: "1968",
            advisors: ["John Doe"],
            builders: ["Jane Smith", "Alice Johnson"],
            description: "An innovative structure built for architectural experimentation.",
            funFact: "This structure uses recycled materials!",
            images: ["example_image"], // Replace with actual asset name
            isVisited: true,
            isOpened: false,
            recentlyVisited: 0,
            isLiked: false
        )
        
        return Group {
            // Light Mode Preview
            VisitNotificationView(structure: randomStructure)
                .environmentObject(appState)
                .environmentObject(dataStore)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Light Mode")
            
            // Dark Mode Preview
            VisitNotificationView(structure: randomStructure)
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
