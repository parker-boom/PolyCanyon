//
//  StructInfo.swift
//  YourApp
//
//  Created by Your Name on 1/21/25.
//

import SwiftUI
import Zoomable

struct StructInfo: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    // MARK: - Local State
    @State private var selectedTab: InfoTab = .info
    
    // MARK: - Computed Property for the Structure
    private var structure: Structure {
        // You can modify how the correct structure is retrieved if needed
        dataStore.structures[appState.structInfoNum - 1]
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.white
                    .ignoresSafeArea(edges: .all)
                
                VStack(spacing: 0) {
                    HeaderView(
                        structure: structure,
                        dismissAction: { appState.activeFullScreenView = nil },
                        safeAreaHeight: geo.size.height * 0.15
                    )
                    
                    // 2) Main Content - ~75% of height
                    ZStack {
                        switch selectedTab {
                        case .info:
                            InfoSectionView(structure: structure, onImageTap: {
                                selectedTab = .images
                            })
                        case .images:
                            ImagesSectionView(structure: structure, selectedTab: $selectedTab)
                        }
                    }
                    .frame(height: geo.size.height * 0.78)
                    
                    // 3) Bottom Picker - ~10% of height
                    BottomTabPicker(selectedTab: $selectedTab)
                        .frame(height: geo.size.height * 0.07)
                }
                

            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            if structure.isVisited && !structure.isOpened {
                dataStore.markStructureAsOpened(structure.number)
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

// MARK: - HeaderView
/// Top header with a circle for the structure number (left), a large (possibly multiline) title in the center,
/// and an `X` button in a circle on the right to dismiss.
fileprivate struct HeaderView: View {
    let structure: Structure
    let dismissAction: () -> Void
    let safeAreaHeight: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.gray.opacity(0.15)
                .frame(height: safeAreaHeight)
                .background(Color.gray.opacity(0.15))
                .ignoresSafeArea(edges: .top)
                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.thinMaterial)
                            .shadow(color: .black.opacity(0.65), radius: 4)
                        Text("\(structure.number)")
                            .font(.system(size: 22, weight: .black))
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
/// 1) A row: [Image with year overlay, Fun Fact next to it]
/// 2) A collapsible description (starts expanded)
/// 3) Builders row
/// 4) Advisors row
fileprivate struct InfoSectionView: View {
    let structure: Structure
    let onImageTap: () -> Void 
    @State private var isDescriptionExpanded = true
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 15) {
                // Top Row - Fixed size containers
                HStack(spacing: 15) {
                    // Image Container - Fixed size
                    ZStack(alignment: .bottomTrailing) {
                        if let firstImage = structure.images.first {
                            Image(firstImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200)
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
                                .padding(8)
                        }
                        
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.85), radius: 5, y: 2)
                            .shadow(color: .white.opacity(0.45), radius: 5, y: 2)
                            .padding(12)
                            .position(x: 180, y: 20)
                    }
                    .frame(width: 200, height: 200)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.75), radius: 5, y: 2)
                    .onTapGesture {
                        onImageTap()
                    }
                    
                    // Fun Fact Container - Fixed size
                    if let fact = structure.funFact, !fact.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("💯")
                                    .font(.system(size: 14, weight: .bold))
                                Text("FUN FACT")
                                    .font(.system(size: 20, weight: .bold))
                                
                                Spacer()
                            }
                            .padding(.top, 10)
                            
                            Text(fact)
                                .font(.system(size: 22))
                                .padding(.top, 5)
                                .lineSpacing(4)
                                .minimumScaleFactor(0.5)
                                .lineLimit(8)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.35), radius: 5, y: 2)
                    }
                }
                
                // Description Box - Full width with padding
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: { isDescriptionExpanded.toggle() }) {
                        HStack {
                            Text("📝")
                                .font(.system(size: 14, weight: .bold))
                            Text("DESCRIPTION")
                                .font(.system(size: 20, weight: .bold))
                            Spacer()
                            Image(systemName: isDescriptionExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.primary)
                    }
                    
                    if isDescriptionExpanded {
                        Text(structure.description)
                            .font(.system(size: 20))
                            .padding(.top, 4)
                            .lineSpacing(5)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.35), radius: 5, y: 2)
                
                // Builders Row - Full width with padding
                if !structure.builders.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack{
                            Text("👷")
                                .font(.system(size: 14, weight: .bold))
                            Text("BUILDERS")
                                .font(.system(size: 18, weight: .bold))
                        }
                        Text(structure.builders.joined(separator: ", "))
                            .font(.system(size: 20))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.35), radius: 5, y: 2)
                }
                
                // Advisors Row - Full width with padding
                if !structure.advisors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack{
                            Text("🎓")
                                .font(.system(size: 14, weight: .bold))
                            Text("ADVISORS")
                                .font(.system(size: 18, weight: .bold))
                        }
                        Text(structure.advisors.joined(separator: ", "))
                            .font(.system(size: 20))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
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

// MARK: - ImagesSectionView
/// Main content for the "Images" tab. Shows a full-screen image with blurred background behind it,
/// plus a dot indicator at the bottom. The user can swipe horizontally through all structure images.
fileprivate struct ImagesSectionView: View {
    let structure: Structure
    @Binding var selectedTab: InfoTab
    @EnvironmentObject var dataStore: DataStore
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
                
                // Like Button Overlay
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
                        
                        Button(action: { dataStore.toggleLike(for: structure.id) }) {
                            Image(systemName: dataStore.isLiked(for: structure.id) ? "heart.fill" : "heart")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(dataStore.isLiked(for: structure.id) ? .red : .white)
                                .shadow(color: .black.opacity(0.85), radius: 5, y: 2)
                                .shadow(color: .white.opacity(0.65), radius: 5, y: 2)
                        }
                        .padding(25)
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
struct StructInfo_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light Mode Preview
            StructInfo()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = false
                    state.structInfoNum = getRandomStructureNumber()
                    return state
                }())
                .environmentObject(DataStore())
                .previewDisplayName("Light Mode")
            
            // Dark Mode Preview
            StructInfo()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = true
                    state.structInfoNum = getRandomStructureNumber()
                    return state
                }())
                .environmentObject(DataStore())
                .previewDisplayName("Dark Mode")
        }
    }

    // Generate a random structure number for preview
    private static func getRandomStructureNumber() -> Int {
        return Int.random(in: 1...31) // Adjust range based on the mock structures
    }
}
