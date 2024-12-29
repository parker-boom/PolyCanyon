/*
 StructInfo displays detailed information about a structure with an interactive flip animation. The front 
 shows an image carousel with basic details, while the back shows extended information. It supports image 
 zooming, structure liking, and provides visual feedback for visited/opened states. The view adapts to the 
 app theme and handles gesture-based dismissal.
*/

import SwiftUI
import Zoomable
import Shimmer

// MARK: - StructInfo (Top-Level Container)
struct StructInfo: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    // MARK: - Properties
    let structure: Structure
    @Binding var isPresented: Bool
    
    // MARK: - View State
    @State private var isShowingInfo: Bool = false
    @State private var currentImageIndex: Int = 0
    @State private var isLiked: Bool
    
    // MARK: - Initializer
    init(structure: Structure, isPresented: Binding<Bool>) {
        self.structure = structure
        self._isPresented = isPresented
        self._isLiked = State(initialValue: structure.isLiked)
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 15) {
                
                // Flip between image section and info panel
                ZStack {
                    if !isShowingInfo {
                        ImageSection(
                            structure: structure,
                            currentImageIndex: $currentImageIndex,
                            isLiked: $isLiked,
                            dismissAction: { isPresented = false },
                            geometry: geometry
                        )
                    } else {
                        InformationPanel(
                            structure: structure,
                            isPresented: $isPresented,
                            geometry: geometry
                        )
                    }
                }
                .rotation3DEffect(.degrees(isShowingInfo ? 180 : 0),
                                  axis: (x: 0, y: 1, z: 0))
                .animation(.easeInOut(duration: 0.5), value: isShowingInfo)
                .onAppear {
                    if structure.isVisited {
                        dataStore.markStructureAsOpened(structure.number)
                    }
                }
                
                // Button to toggle image/info
                ToggleInfoButton(isShowingInfo: $isShowingInfo, geometry: geometry)
            }
            .padding(15)
            .background(appState.isDarkMode ? Color.black : Color.white)
            .cornerRadius(20)
            .shadow(color: appState.isDarkMode ? .white.opacity(0.3) : .black.opacity(0.5),
                    radius: 7, x: 0, y: 3)
            .gesture(dismissDragGesture)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Drag-to-Dismiss Gesture
    private var dismissDragGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                // If user drags down enough, dismiss
                if value.translation.height > 100 {
                    isPresented = false
                }
            }
    }
}

// MARK: - Image Section
/// Shows the image carousel, dismiss button, structure info overlay, and image indicator dots.
private struct ImageSection: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    let structure: Structure
    @Binding var currentImageIndex: Int
    @Binding var isLiked: Bool
    
    let dismissAction: () -> Void
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Carousel
            ImprovedImageCarousel(
                mainPhoto: structure.mainPhoto,
                closeUp: structure.closeUp,
                currentImageIndex: $currentImageIndex,
                geometry: geometry
            )
            .frame(height: geometry.size.height * 0.75)
            .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
            
            // Dismiss button (top trailing)
            DismissButton { dismissAction() }
            
            // Structure info overlay (bottom leading)
            StructureInfoOverlay(structure: structure)
            
            // Like + image indicator dots (bottom trailing)
            ImageDotsView(
                structure: structure,
                currentImageIndex: $currentImageIndex,
                isLiked: $isLiked
            )
        }
    }
}

// MARK: - Information Panel
/// Flipped view that shows extended details about the structure.
private struct InformationPanel: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    let structure: Structure
    @Binding var isPresented: Bool
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 0) {
            InfoPanelHeader(
                structure: structure,
                dismissAction: { isPresented = false }
            )
            
            // Scroll view of cards in info panel
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    if structure.builders != "iii" {
                        InfoPill(
                            icon: "👷",
                            title: "Builders",
                            value: structure.builders
                        )
                    }
                    
                    if let funFact = structure.funFact, funFact != "iii" {
                        FunFactPill(
                            icon: "✨",
                            fact: funFact
                        )
                    }
                    
                    InfoPill(
                        icon: "📝",
                        title: "Description",
                        value: structure.description
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
            }
        }
        .frame(height: geometry.size.height * 0.75)
        .background(appState.isDarkMode ? Color.black : Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
}

// MARK: - ToggleInfoButton
/// A button to toggle between the image carousel and the information panel.
private struct ToggleInfoButton: View {
    @EnvironmentObject var appState: AppState
    @Binding var isShowingInfo: Bool
    let geometry: GeometryProxy
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.5)) {
                isShowingInfo.toggle()
            }
        }) {
            HStack {
                Text(isShowingInfo ? "Images  " : "Information  ")
                    .font(.system(size: 22, weight: .semibold))
                
                Image(systemName: isShowingInfo ? "photo" : "info.circle")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(appState.isDarkMode ? .white : .black)
            .padding()
            .frame(width: geometry.size.width - 30)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
        }
    }
}

// MARK: - InfoPanelHeader
/// Header for the information panel, displaying structure number, title, and year (if any).
private struct InfoPanelHeader: View {
    @EnvironmentObject var appState: AppState
    
    let structure: Structure
    let dismissAction: () -> Void
    
    var body: some View {
        HStack {
            Text("\(structure.number)")
                .font(.system(size: 30, weight: .bold))
            
            Spacer()
            
            VStack {
                Text(structure.title)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                
                if structure.year != "xxxx" {
                    Text(structure.year)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
                }
            }
            
            Spacer()
            
            Button(action: {
                dismissAction()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(appState.isDarkMode ? .white : .black)
            }
        }
        .padding()
        .background(appState.isDarkMode ? Color.black : Color.white)
    }
}

// MARK: - DismissButton
/// A simple top-right "X" button to dismiss the entire view.
private struct DismissButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2, x: 0, y: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}

// MARK: - StructureInfoOverlay
/// Overlay showing the structure number and title at bottom-left of the image section.
private struct StructureInfoOverlay: View {
    let structure: Structure
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("\(structure.number)")
                .font(.system(size: 40, weight: .bold))
            Text(structure.title)
                .font(.system(size: 30, weight: .semibold))
        }
        .foregroundColor(.white)
        .shadow(color: .black, radius: 2, x: 0, y: 0)
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}

// MARK: - ImageDotsView
/// Shows a like button plus dots indicating which image is currently displayed in the carousel.
private struct ImageDotsView: View {
    @EnvironmentObject var dataStore: DataStore
    
    let structure: Structure
    @Binding var currentImageIndex: Int
    @Binding var isLiked: Bool
    
    var body: some View {
        VStack {
            // Like button
            LikeButton(structure: structure, isLiked: $isLiked)
            
            // Dots
            HStack(spacing: 8) {
                ForEach(0..<2) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(width: currentImageIndex == index ? 10 : 8,
                               height: currentImageIndex == index ? 10 : 8)
                        .opacity(currentImageIndex == index ? 1 : 0.5)
                }
            }
            .padding(10)
            .background(Color.black.opacity(0.6))
            .cornerRadius(15)
            .padding(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
}

// MARK: - LikeButton
/// A button that toggles the "liked" status of a structure.
private struct LikeButton: View {
    @EnvironmentObject var dataStore: DataStore
    
    let structure: Structure
    @Binding var isLiked: Bool

    var body: some View {
        Button(action: {
            isLiked.toggle()
            dataStore.toggleLike(for: structure.id)
        }) {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .foregroundColor(isLiked ? .red : .white)
                .font(.system(size: 42))
                .shadow(color: .black, radius: 2, x: 0, y: 0)
        }
    }
}

// MARK: - InfoPill
/// Displays a small “pill” with an icon, title, and a text value.
private struct InfoPill: View {
    @EnvironmentObject var appState: AppState
    
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                    .font(.system(size: 18, weight: .bold))
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(appState.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            Text(value)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(appState.isDarkMode ? .white : .black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(appState.isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
        .cornerRadius(20)
        .shadow(
            color: appState.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1),
            radius: 5, x: 0, y: 2
        )
    }
}

// MARK: - FunFactPill
/// A special pill that highlights a fun fact with a shimmering border.
private struct FunFactPill: View {
    @EnvironmentObject var appState: AppState
    
    let icon: String
    let fact: String
    @State private var isGlowing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(icon)
                    .font(.system(size: 18, weight: .bold))
                Text("Fun Fact")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(appState.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            Text(fact)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(appState.isDarkMode ? .white.opacity(0.9) : .black.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(appState.isDarkMode ? Color.blue.opacity(0.2) : Color.blue.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(appState.isDarkMode ? Color.blue.opacity(0.6) : Color.blue.opacity(0.8), lineWidth: 2)
                .shimmering(
                    animation: .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    bandSize: 0.3
                )
        )
        .shadow(
            color: isGlowing ? (appState.isDarkMode ? .blue.opacity(0.4) : .blue.opacity(0.2)) : .clear,
            radius: 10, x: 0, y: 0
        )
        .scaleEffect(isGlowing ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isGlowing)
        .onAppear {
            self.isGlowing = true
        }
    }
}

// MARK: - ImprovedImageCarousel
/// A carousel for the structure's main and close-up images with a zoomable subview.
private struct ImprovedImageCarousel: View {
    let mainPhoto: String
    let closeUp: String
    @Binding var currentImageIndex: Int
    let geometry: GeometryProxy

    var body: some View {
        TabView(selection: $currentImageIndex) {
            ZoomableImageView(imageName: mainPhoto)
                .tag(0)
            ZoomableImageView(imageName: closeUp)
                .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(width: geometry.size.width - 30, height: geometry.size.height * 0.75)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - ZoomableImageView
/// An image that can be pinch-zoomed and panned.
private struct ZoomableImageView: View {
    let imageName: String
    

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            ZStack {
                // Blurred background
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .blur(radius: 20)
                
                // Foreground image
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
                    .scaleEffect(1.2)
                    .zoomable(
                        minZoomScale: 1.0,
                        doubleTapZoomScale: 2.0
                    )
            }
            .clipped()
        }
    }
}

// MARK: - Preview
struct StructInfo_Previews: PreviewProvider {
    static var previews: some View {
        let exampleStructure = DataStore.shared.structures.randomElement() ?? Structure(
            id: 999,
            title: "Preview Structure",
            number: 99,
            description: "Preview of a structure.",
            mainPhoto: "PlaceholderMain",
            closeUp: "PlaceholderCloseUp"
        )
        
        Group {
            StructInfo(structure: exampleStructure, isPresented: .constant(true))
                .environmentObject(AppState())
                .environmentObject(DataStore.shared)
                .previewDisplayName("Light Mode")
            
            StructInfo(structure: exampleStructure, isPresented: .constant(true))
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = true
                    return state
                }())
                .environmentObject(DataStore.shared)
                .previewDisplayName("Dark Mode")
        }
    }
}