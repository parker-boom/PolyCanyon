//
//  StructInfo.swift
//  YourApp
//
//  Created by Your Name on 1/21/25.
//

import SwiftUI
import Zoomable

struct GhostInfo: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    // MARK: - Local State
    @State private var selectedTab: InfoTab = .info
    @State private var currentGhostIndex: Int = 0
    
    // Index of the ghost structure to initially display
    var initialGhostIndex: Int?
    
    // MARK: - Computed Properties
    private var ghostStructure: GhostStructure {
        dataStore.ghostStructures[currentGhostIndex]
    }
    
    private var structureForDisplay: Structure {
        dataStore.ghostStructureToDisplayStructure(ghostStructure)
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.white
                    .ignoresSafeArea(edges: .all)
                
                VStack(spacing: 0) {
                    // Use the HeaderView with integrated ghost navigation
                    GhostHeaderView(
                        structure: structureForDisplay,
                        currentIndex: $currentGhostIndex, 
                        totalCount: dataStore.ghostStructures.count,
                        dismissAction: { appState.activeFullScreenView = nil },
                        safeAreaHeight: geo.size.height * 0.15
                    )
                    
                    // Main Content - ~78% of height
                    ZStack {
                        switch selectedTab {
                        case .info:
                            InfoSectionView(
                                structure: structureForDisplay,
                                onImageTap: { selectedTab = .images },
                                currentIndex: $currentGhostIndex,
                                totalCount: dataStore.ghostStructures.count
                            )
                        case .images:
                            ImagesSectionView(structure: structureForDisplay, selectedTab: $selectedTab)
                        }
                    }
                    .frame(height: geo.size.height * 0.78)
                    
                    // Bottom Picker - ~7% of height
                    BottomTabPicker(selectedTab: $selectedTab)
                        .frame(height: geo.size.height * 0.07)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            // Set initial ghost structure index if provided
            if let initialIndex = initialGhostIndex, initialIndex >= 0 && initialIndex < dataStore.ghostStructures.count {
                currentGhostIndex = initialIndex
            }
        }
    }
}

// MARK: - InfoTab Enum
/// Tracks which tab is currently selected at the bottom (Info or Images).
fileprivate enum InfoTab {
    case info
    case images
}

// MARK: - GhostHeaderView
/// Top header with a ghost emoji (left), a large title in the center,
/// an `X` button in a circle on the right to dismiss, and ghost structure navigation info.
fileprivate struct GhostHeaderView: View {
    let structure: Structure
    @Binding var currentIndex: Int
    let totalCount: Int
    let dismissAction: () -> Void
    let safeAreaHeight: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.gray.opacity(0.15)
                .frame(height: safeAreaHeight)
                .background(Color.gray.opacity(0.15))
                .ignoresSafeArea(edges: .top)
                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
            
            VStack(spacing: 8) {

                // Main header with title and emoji
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.thinMaterial)
                            .shadow(color: .black.opacity(0.65), radius: 4)
                        Text("👻")
                            .font(.system(size: 22))
                    }
                    .frame(width: 44, height: 44)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.thinMaterial)
                            .shadow(color: .black.opacity(0.65), radius: 3)
                        
                        Text(structure.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .shadow(color: .white.opacity(0.65), radius: 3, y: 0)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                            .padding(.horizontal, 16)
                    }
                    .frame(height: 44)
                    
                    Button(action: dismissAction) {
                        ZStack {
                            Circle()
                                .fill(.thinMaterial)
                                .shadow(color: .black.opacity(0.65), radius: 4)
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .black))
                                .foregroundColor(.black)
                        }
                    }
                    .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 12)
        }
    }
}

// MARK: - InfoSectionView
/// Main Content for the "Info" tab. This is a scroll view with:
/// 1) A row: [Image with year overlay, Navigation Buttons next to it]
/// 2) A collapsible description (starts expanded)
/// 3) Builders row
/// 4) Advisors row
fileprivate struct InfoSectionView: View {
    let structure: Structure
    let onImageTap: () -> Void 
    @Binding var currentIndex: Int
    let totalCount: Int
    @State private var isDescriptionExpanded = true
    
    var body: some View {
        GeometryReader { geo in
            let availableWidth = geo.size.width - 30 // Account for horizontal padding
            let imageWidth = min(220, availableWidth * 0.45) // Cap at 220pt or 45% of width
            let spacing = availableWidth > 360 ? 10.0 : 8.0 // Reduce spacing on smaller screens
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    // Top Row - Adaptive size containers
                    HStack(spacing: spacing) {
                        // Image Container - Responsive width
                        ZStack(alignment: .bottomTrailing) {
                            if let firstImage = structure.images.first {
                                Image(firstImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: imageWidth, height: imageWidth * 0.82) // Maintain aspect ratio
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            
                            if structure.year != "xxxx" {
                                Text(structure.year)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.65), radius: 3)
                                    .padding(6)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .padding(10)
                            }
                            
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.85), radius: 5, y: 2)
                                .shadow(color: .white.opacity(0.45), radius: 5, y: 2)
                                .padding(12)
                                .position(x: imageWidth * 0.88, y: 25) // Position relative to image width
                        }
                        .frame(width: imageWidth, height: imageWidth * 0.82)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.75), radius: 5, y: 2)
                        .onTapGesture {
                            onImageTap()
                        }
                        
                        // Navigation Controls instead of fun fact - responsive width
                        VStack(alignment: .center, spacing: availableWidth > 360 ? 20 : 10) {
                            Text("Ghost Structures")
                                .font(.system(size: availableWidth > 360 ? 20 : 18, weight: .bold))
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                            
                            Text("\(currentIndex + 1) of \(totalCount)")
                                .font(.system(size: availableWidth > 360 ? 16 : 14))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: availableWidth > 360 ? 30 : 20) {
                                Button(action: previousGhost) {
                                    Image(systemName: "arrow.left.circle.fill")
                                        .font(.system(size: availableWidth > 360 ? 40 : 32))
                                        .foregroundColor(currentIndex > 0 ? .black : .gray.opacity(0.5))
                                        .shadow(color: .black.opacity(0.2), radius: 3)
                                }
                                .disabled(currentIndex == 0)
                                
                                Button(action: nextGhost) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: availableWidth > 360 ? 40 : 32))
                                        .foregroundColor(currentIndex < totalCount - 1 ? .black : .gray.opacity(0.5))
                                        .shadow(color: .black.opacity(0.2), radius: 3)
                                }
                                .disabled(currentIndex == totalCount - 1)
                            }
                            .padding(.top, availableWidth > 360 ? 10 : 5)
                        }
                        .padding(.horizontal, availableWidth > 360 ? 15 : 10)
                        .frame(width: availableWidth - imageWidth - spacing)
                        .frame(height: imageWidth * 0.82)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.35), radius: 5, y: 2)
                    }
                    
                    // Description Box - Full width with adaptive padding
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: { isDescriptionExpanded.toggle() }) {
                            HStack {
                                Text("📝")
                                    .font(.system(size: 14, weight: .bold))
                                Text("DESCRIPTION")
                                    .font(.system(size: availableWidth > 360 ? 20 : 18, weight: .bold))
                                Spacer()
                                Image(systemName: isDescriptionExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.primary)
                        }
                        
                        if isDescriptionExpanded {
                            Text(structure.description)
                                .font(.system(size: availableWidth > 360 ? 20 : 18))
                                .padding(.top, 4)
                                .lineSpacing(5)
                                .fixedSize(horizontal: false, vertical: true) // Allow proper text wrapping
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(availableWidth > 360 ? 16 : 12)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.35), radius: 5, y: 2)
                    
                    // Builders Row - Full width with adaptive padding
                    if !structure.builders.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack{
                                Text("👷")
                                    .font(.system(size: 14, weight: .bold))
                                Text("BUILDERS")
                                    .font(.system(size: availableWidth > 360 ? 18 : 16, weight: .bold))
                            }
                            Text(structure.builders.joined(separator: ", "))
                                .font(.system(size: availableWidth > 360 ? 20 : 18))
                                .fixedSize(horizontal: false, vertical: true) // Allow proper text wrapping
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(availableWidth > 360 ? 16 : 12)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.35), radius: 5, y: 2)
                    }
                    
                    // Advisors Row - Full width with adaptive padding
                    if !structure.advisors.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack{
                                Text("🎓")
                                    .font(.system(size: 14, weight: .bold))
                                Text("ADVISORS")
                                    .font(.system(size: availableWidth > 360 ? 18 : 16, weight: .bold))
                            }
                            Text(structure.advisors.joined(separator: ", "))
                                .font(.system(size: availableWidth > 360 ? 20 : 18))
                                .fixedSize(horizontal: false, vertical: true) // Allow proper text wrapping
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(availableWidth > 360 ? 16 : 12)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.35), radius: 5, y: 2)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 20)
            }
        }
    }
    
    private func previousGhost() {
        if currentIndex > 0 {
            withAnimation {
                currentIndex -= 1
            }
        }
    }
    
    private func nextGhost() {
        if currentIndex < totalCount - 1 {
            withAnimation {
                currentIndex += 1
            }
        }
    }
}

// MARK: - ImagesSectionView
/// Main content for the "Images" tab. Shows a full-screen image with blurred background behind it,
/// plus a dot indicator at the bottom. The user can swipe horizontally through all structure images.
fileprivate struct ImagesSectionView: View {
    let structure: Structure
    @Binding var selectedTab: InfoTab
    @State private var currentIndex: Int = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // TabView for images
                TabView(selection: $currentIndex) {
                    ForEach(structure.images.indices, id: \.self) { idx in
                        // Each page: blurred background + main image
                        ZStack {
                            // Blurred background
                            Image(structure.images[idx])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .blur(radius: 8)
                                .clipped()
                            
                            // Foreground image scaled to fit
                            Image(structure.images[idx])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                                .zoomable()
                        }
                        .tag(idx)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Dot indicator overlay (bottom center)
                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        ForEach(structure.images.indices, id: \.self) { dotIndex in
                            Circle()
                                .fill(dotIndex == currentIndex ? Color.white : Color.white.opacity(0.4))
                                .frame(width: dotIndex == currentIndex ? 10 : 8,
                                       height: dotIndex == currentIndex ? 10 : 8)
                                .shadow(color: .black.opacity(0.85), radius: 5, y: 2)
                                .shadow(color: .white.opacity(0.65), radius: 5, y: 2)
                        }
                    }
                    .padding(.bottom, 30)
                }
                
                // Back to Info button, no like button for ghost structures
                VStack {
                    Spacer()
                    HStack {
                        Button(action: { selectedTab = .info }) {
                            Image(systemName: "arrow.down.right.and.arrow.up.left")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.85), radius: 5, y: 2)
                                .shadow(color: .white.opacity(0.65), radius: 5, y: 2)
                        }
                        .padding(25)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - BottomTabPicker
/// A custom bottom picker (or toggle) that shows the currently selected tab in text/icon form,
/// plus a button to switch to the other tab. The exact style can be further tweaked.
fileprivate struct BottomTabPicker: View {
    @Binding var selectedTab: InfoTab
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.15)
                .background(Color.gray.opacity(0.15))
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
            
            HStack {
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.thinMaterial)
                        .shadow(color: .black.opacity(0.4), radius: 3)
                    
                    HStack(spacing: 15) {
                        Button(action: { selectedTab = .info }) {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                if selectedTab == .info {
                                    Text("Info")
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                            .foregroundColor(selectedTab == .info ? .black : .gray)
                            .frame(width: 120)
                        }
                        
                        Divider()
                            .frame(width: 1)
                            .background(Color.black.opacity(0.4))
                        
                        Button(action: { selectedTab = .images }) {
                            HStack(spacing: 6) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                if selectedTab == .images {
                                    Text("Images")
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                            .padding(.trailing, 20)
                            .foregroundColor(selectedTab == .images ? .black : .gray)
                            .frame(width: 120)
                        }
                    }
                }
                .frame(width: 220, height: 38)
                
                Spacer()
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Preview
struct GhostInfo_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light Mode Preview
            GhostInfo()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = false
                    return state
                }())
                .environmentObject(DataStore.shared)
                .previewDisplayName("Light Mode")
            
            // Dark Mode Preview
            GhostInfo()
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
