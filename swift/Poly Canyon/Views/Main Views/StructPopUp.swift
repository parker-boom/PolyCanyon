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


struct StructPopUp: View {
    // MARK: - Properties
    @ObservedObject var structureData: StructureData
    let structure: Structure
    @Binding var isDarkMode: Bool
    @Binding var isPresented: Bool
    @State private var dragOffset: CGSize = .zero
    @State private var isShowingInfo: Bool = false
    @State private var selectedTab: Int = 0
    @State private var currentImageIndex: Int = 0
    @State private var isLiked: Bool

    // MARK: - Initialization
    init(structureData: StructureData, structure: Structure, isDarkMode: Binding<Bool>, isPresented: Binding<Bool>) {
        self._structureData = ObservedObject(wrappedValue: structureData)
        self.structure = structure
        self._isDarkMode = isDarkMode
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

    // MARK: - UI Components
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

    // MARK: - Information Panel
    @ViewBuilder
    private func informationPanel(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            headerView
            
            CustomTabSelector(selectedTab: $selectedTab)
                .padding(.top, 15)
                .padding(.bottom, 10)
            
            TabView(selection: $selectedTab) {
                statisticsView(geometry: geometry)
                    .tag(0)
                descriptionView
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
            Text(structure.title)
                .font(.system(size: 24, weight: .semibold))
            Spacer()
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isShowingInfo.toggle()
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isDarkMode ? .white : .black)
            }
        }
        .padding()
        .background(isDarkMode ? Color.black : Color.white)
    }

    private func statisticsView(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 10) {
                    if structure.year != "iii" {
                        InfoPill(icon: "📅", title: "Year", value: structure.year)
                    }
                    if structure.architecturalStyle != "iii" {
                        InfoPill(icon: "🏛️", title: "Style", value: structure.architecturalStyle)
                    }
                }

                if structure.students != "iii" || structure.advisors != "iii" {
                    InfoPill(icon: "👷", title: "Builders", value: "\(structure.students) \(structure.advisors)")
                        .frame(height: 80)
                }

                if structure.additionalInfo != "iii" {
                    FunFactPill(icon: "✨", fact: structure.additionalInfo ?? "No fun fact available")
                        .frame(height: 100)
                }
            }
            .padding(15)
        }
    }

    private var descriptionView: some View {
        ScrollView {
            Text(structure.description)
                .font(.system(size: 20))
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.horizontal, 10)
                .padding(.top, 10)
                .multilineTextAlignment(.center)
        }
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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(icon)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
        .cornerRadius(20)
    }
}

struct FunFactPill: View {
    let icon: String
    let fact: String
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(icon)
                Text("Fun Fact")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            Text(fact)
                .font(.system(size: 16, weight: .medium))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(colorScheme == .dark ? Color.blue.opacity(0.3) : Color.blue.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue.opacity(colorScheme == .dark ? 0.7 : 0.5), lineWidth: 2)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .opacity(isAnimating ? 0.8 : 0.4)
                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
        )
        .onAppear {
            isAnimating = true
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
            number: 1,
            title: "Sample Structure",
            description: "This is a sample description",
            year: "2023",
            students: "John Doe, Jane Smith",
            advisors: "Prof. Johnson",
            additionalInfo: "Additional information here",
            architecturalStyle: "Modern",
            mainPhoto: "1M",
            closeUp: "1C",
            isVisited: false,
            isOpened: false,
            recentlyVisited: -1,
            isLiked: false
        )
        
        return StructPopUp(
            structureData: mockStructureData,
            structure: mockStructure,
            isDarkMode: .constant(false),
            isPresented: .constant(true)
        )
    }
}
