// MARK: - Overview
/*
    StructPopUp.swift

    This file defines the StructPopUp view, which displays detailed information about a selected structure in the Poly Canyon app.

    Key Components:
    - Swipeable main and close-up images with indicator dots
    - Animated information panel
    - Custom tab selector for stats and description
    - Dark mode support
    - Dismiss button and structure title/number overlay

    The view is designed to be presented as a sheet and adapts its layout based on the device's screen size.
*/

import SwiftUI
import Zoomable
import Shimmer



struct StructPopUp: View {
    @ObservedObject var structureData: StructureData
    let structure: Structure
    @Binding var isDarkMode: Bool
    @Binding var isPresented: Bool
    @State private var dragOffset: CGSize = .zero
    @State private var isShowingInfo: Bool = false
    @State private var currentImageIndex: Int = 0
    @State private var isLiked: Bool

    init(structureData: StructureData, structure: Structure, isDarkMode: Binding<Bool>, isPresented: Binding<Bool>) {
        self._structureData = ObservedObject(wrappedValue: structureData)
        self.structure = structure
        self._isDarkMode = isDarkMode
        self._isPresented = isPresented
        self._isLiked = State(initialValue: structure.isLiked)
    }

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

                informationButton(geometry: geometry)
            }
            .padding(15)
            .background(isDarkMode ? Color.black : Color.white)
            .cornerRadius(20)
            .shadow(color: isDarkMode ? .white.opacity(0.3) : .black.opacity(0.5), radius: 7, x: 0, y: 3)
            .offset(y: dragOffset.height)
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

    private func imageCarousel(geometry: GeometryProxy) -> some View {
        ImprovedImageCarousel(mainPhoto: structure.mainPhoto, closeUp: structure.closeUp, currentImageIndex: $currentImageIndex, geometry: geometry)
    }

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
            .foregroundColor(isDarkMode ? .white : .black)
            .padding()
            .frame(width: geometry.size.width - 30)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
        }
    }

    private func informationPanel(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    if structure.builders != "iii" {
                        InfoPill(icon: "👷", title: "Builders", value: structure.builders, isDarkMode: isDarkMode)
                    }
                    
                    if structure.funFact != "iii" {
                        FunFactPill(icon: "✨", fact: structure.funFact ?? "No fun fact available", isDarkMode: $isDarkMode)
                    }
                    
                    InfoPill(icon: "📝", title: "Description", value: structure.description, isDarkMode: isDarkMode)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
            }
        }
        .frame(height: geometry.size.height * 0.75)
        .background(isDarkMode ? Color.black : Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }

    private var headerView: some View {
        HStack {
            Text("\(structure.number)")
                .font(.system(size: 30, weight: .bold))
            Spacer()
            VStack {
                Text(structure.title)
                    .font(.system(size: 24, weight: .bold))
                Text(structure.year)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
            }
            Spacer()
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isDarkMode ? .white : .black)
            }
        }
        .padding()
        .background(isDarkMode ? Color.black : Color.white)
    }
}


// MARK: - Supporting Views
struct CustomTabSelector: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack {
            TabButton(icon: "chart.bar.fill", title: "Stats", isSelected: selectedTab == 0) {
                selectedTab = 0
            }

            TabButton(icon: "info.circle.fill", title: "Info", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
    }
}

struct LikeButton: View {
    @ObservedObject var structureData: StructureData
    let structure: Structure
    @Binding var isLiked: Bool

    var body: some View {
        Button(action: {
            isLiked.toggle()
            structureData.toggleLike(for: structure.id)
        }) {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .foregroundColor(isLiked ? .red : .white)
                .font(.system(size: 42))
        }
    }
}


struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 16, weight: .semibold))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.blue : Color.clear)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(15)
        }
    }
}

struct InfoPill: View {
    let icon: String
    let title: String
    let value: String
    let isDarkMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                    .font(.system(size: 18, weight: .bold))
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            Text(value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(isDarkMode ? .white : .black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
        .cornerRadius(20)
        .shadow(color: isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


struct FunFactPill: View {
    let icon: String
    let fact: String
    @Binding var isDarkMode: Bool
    @State private var isGlowing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(icon)
                    .font(.system(size: 18, weight: .bold))
                Text("Fun Fact")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            Text(fact)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isDarkMode ? .white.opacity(0.9) : .black.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(isDarkMode ? Color.blue.opacity(0.2) : Color.blue.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isDarkMode ? Color.blue.opacity(0.6) : Color.blue.opacity(0.8), lineWidth: 2)
                .shimmering(
                    animation: .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    bandSize: 0.3
                )
        )
        .shadow(
            color: isGlowing ? (isDarkMode ? .blue.opacity(0.4) : .blue.opacity(0.2)) : .clear,
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
        let mockStructureData = StructureData()
        let mockStructure = Structure(
            number: 8,
            title: "Geodesic Dome",
            description: "The Geodesic Dome, an iconic structure in Poly Canyon, stands as a testament to innovative architectural design and engineering principles. Constructed in 1957, it showcases the visionary concepts of Buckminster Fuller, who popularized this efficient structural form. The dome's lattice-shell structure is composed of interconnected triangles, creating a self-supporting framework that distributes stress evenly across its surface. This design not only provides exceptional strength-to-weight ratio but also maximizes interior space with minimal material usage. The Geodesic Dome serves as an enduring example of sustainable architecture and continues to inspire students and visitors alike with its futuristic appearance and practical applications in modern construction techniques.",
            year: "1957",
            builders: "John Warren, Myles Murphey, Don Mills, Jack Stammer, Neil Moir, Don Tanklage, Bill Kohr",
            funFact: "The Geodesic Dome can withstand extreme weather conditions and has inspired similar structures worldwide, including the famous Spaceship Earth at Walt Disney World's Epcot Center.",
            mainPhoto: "8M",
            closeUp: "8C",
            isVisited: true,
            isOpened: true,
            recentlyVisited: 2,
            isLiked: true
        )
        
        Group {
            StructPopUp(
                structureData: mockStructureData,
                structure: mockStructure,
                isDarkMode: .constant(false),
                isPresented: .constant(true)
            )
            .previewDisplayName("Light Mode")

            StructPopUp(
                structureData: mockStructureData,
                structure: mockStructure,
                isDarkMode: .constant(true),
                isPresented: .constant(true)
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
