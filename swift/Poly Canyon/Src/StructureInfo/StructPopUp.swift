// MARK: - StructPopUp.swift

/*
    StructPopUp.swift

    This file defines the StructPopUp view, which displays detailed information about a selected structure in the Poly Canyon app.

    Key Components:
    - Swipeable main and close-up images with indicator dots
    - Animated information panel
    - Like button
    - Custom tab selector for stats and description
    - Dark mode support
    - Dismiss button and structure title/number overlay

    The view is designed to be presented as a sheet and adapts its layout based on the device's screen size.
*/

import SwiftUI
import Zoomable
import Shimmer

// MARK: - StructPopUp

struct StructPopUp: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    // MARK: - Properties
    let structure: Structure
    @Binding var isPresented: Bool
    
    // MARK: - State Properties
    @State private var dragOffset: CGSize = .zero
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
                ZStack {
                    if !isShowingInfo {
                        imageSection(geometry: geometry)
                    } else {
                        informationPanel(geometry: geometry)
                    }
                }
                .rotation3DEffect(
                    .degrees(isShowingInfo ? 180 : 0),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                .animation(.easeInOut(duration: 0.5), value: isShowingInfo)
                .onAppear {
                    if structure.isVisited {
                        structureData.markStructureAsOpened(structure.number)
                    }
                }
                
                informationButton(geometry: geometry)
            }
            .padding(15)
            .background(appState.isDarkMode ? Color.black : Color.white)
            .cornerRadius(20)
            .shadow(color: appState.isDarkMode ? .white.opacity(0.3) : .black.opacity(0.5), radius: 7, x: 0, y: 3)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let yOffset = value.translation.height
                        dragOffset = CGSize(width: 0, height: max(0, yOffset))
                    }
                    .onEnded { value in
                        if dragOffset.height > 100 {
                            isPresented = false
                        }
                        dragOffset = .zero
                    }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Sections
    
    /**
     * imageSection
     *
     * Displays the image carousel along with dismiss button, structure info, and image indicator dots.
     */
    private func imageSection(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .topLeading) {
            imageCarousel(geometry: geometry)
            dismissButton
            structureInfo
            imageDots
        }
        .frame(height: geometry.size.height * 0.75)
        .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
    }
    
    /**
     * imageCarousel
     *
     * Renders the image carousel using ImprovedImageCarousel.
     */
    private func imageCarousel(geometry: GeometryProxy) -> some View {
        ImprovedImageCarousel(
            mainPhoto: structure.mainPhoto,
            closeUp: structure.closeUp,
            currentImageIndex: $currentImageIndex,
            geometry: geometry
        )
    }
    
    /**
     * dismissButton
     *
     * A button to dismiss the StructPopUp view.
     */
    private var dismissButton: some View {
        Button(action: {
            isPresented = false
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2, x: 0, y: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
    
    /**
     * structureInfo
     *
     * Displays the structure number and title at the bottom-left corner of the image carousel.
     */
    private var structureInfo: some View {
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
    
    /**
     * imageDots
     *
     * Displays indicator dots below the image carousel to represent the current image.
     */
    private var imageDots: some View {
        VStack {
            LikeButton(structureData: structureData, structure: structure, isLiked: $isLiked)
            
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.white)
                    .frame(width: currentImageIndex == 0 ? 10 : 8, height: currentImageIndex == 0 ? 10 : 8)
                    .opacity(currentImageIndex == 0 ? 1 : 0.5)
                Circle()
                    .fill(Color.white)
                    .frame(width: currentImageIndex == 1 ? 10 : 8, height: currentImageIndex == 1 ? 10 : 8)
                    .opacity(currentImageIndex == 1 ? 1 : 0.5)
            }
            .padding(10)
            .background(Color.black.opacity(0.6))
            .cornerRadius(15)
            .padding(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
    
    /**
     * informationButton
     *
     * A button to toggle between image carousel and information panel.
     */
    private func informationButton(geometry: GeometryProxy) -> some View {
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
    
    /**
     * informationPanel
     *
     * Displays detailed information about the structure when toggled.
     */
    private func informationPanel(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    if structure.builders != "iii" {
                        InfoPill(icon: "👷", title: "Builders", value: structure.builders, isDarkMode: appState.isDarkMode)
                    }
                    
                    if let funFact = structure.funFact, funFact != "iii" {
                        FunFactPill(icon: "✨", fact: funFact, isDarkMode: $appState.isDarkMode)
                    }
                    
                    InfoPill(icon: "📝", title: "Description", value: structure.description, isDarkMode: appState.isDarkMode)
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
    
    /**
     * headerView
     *
     * The header for the information panel, displaying structure number, title, year, and a dismiss button.
     */
    private var headerView: some View {
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
                isPresented = false
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

// MARK: - Supporting Views

/**
 * LikeButton
 *
 * A button that allows users to like or unlike the structure.
 */
struct LikeButton: View {
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
        }
    }
}

/**
 * InfoPill
 *
 * Displays an information pill with an icon, title, and value.
 */
struct InfoPill: View {
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
        .shadow(color: appState.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

/**
 * FunFactPill
 *
 * Displays a fun fact pill with an icon and fact text.
 */
struct FunFactPill: View {
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
            radius: 10,
            x: 0,
            y: 0
        )
        .scaleEffect(isGlowing ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isGlowing)
        .onAppear {
            self.isGlowing = true
        }
    }
}

/**
 * ImprovedImageCarousel
 *
 * A carousel view that displays main and close-up photos with zoomable capabilities.
 */
struct ImprovedImageCarousel: View {
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

/**
 * ZoomableImageView
 *
 * An image view that supports zooming and panning.
 */
struct ZoomableImageView: View {
    let imageName: String
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            ZStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .blur(radius: 20)
                
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

struct StructPopUp_Previews: PreviewProvider {
    static var previews: some View {
        // Get random structure from DataStore
        let previewStructure = DataStore.shared.structures.randomElement()!
        
        Group {
            StructPopUp(
                structure: previewStructure,
                isPresented: .constant(true)
            )
            .environmentObject(AppState())
            .environmentObject(DataStore.shared)
            .previewDisplayName("Light Mode")
            
            StructPopUp(
                structure: previewStructure,
                isPresented: .constant(true)
            )
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
