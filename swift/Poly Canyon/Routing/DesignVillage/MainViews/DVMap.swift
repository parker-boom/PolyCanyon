import SwiftUI

struct DVMap: View {
    @State private var selectedView = MapViewType.overview
    @State private var showPointsOfInterest = true
    @State private var mapScale: CGFloat = 1.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                mapViewSelector
                
                mapContent
                
                controlPanel
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 40)
        }
    }
    
    private var mapViewSelector: some View {
        HStack(spacing: 12) {
            ForEach(MapViewType.allCases, id: \.self) { viewType in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedView = viewType
                    }
                } label: {
                    Text(viewType.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedView == viewType ? 
                                          DVDesignSystem.Colors.text : 
                                          DVDesignSystem.Colors.textSecondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .fill(selectedView == viewType ? 
                                      DVDesignSystem.Colors.yellow.opacity(0.7) : 
                                      DVDesignSystem.Colors.surface)
                                .shadow(color: DVDesignSystem.Colors.shadowColor, 
                                        radius: selectedView == viewType ? 3 : 1, 
                                        x: 0, y: 1)
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            DVDesignSystem.Colors.orange,
                                            DVDesignSystem.Colors.teal
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: selectedView == viewType ? 1.5 : 0
                                )
                        )
                }
                .scaleEffect(selectedView == viewType ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedView)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(DVDesignSystem.Components.card())
    }
    
    private var mapContent: some View {
        VStack(spacing: 0) {
            ZStack {
                // Map Image based on selected view
                Image(selectedView.imageName)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(mapScale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / mapScale
                                mapScale = min(max(1.0, mapScale * delta), 3.0)
                            }
                    )
                
                // Points of Interest overlays (if enabled)
                if showPointsOfInterest {
                    mapOverlays
                }
            }
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .background(DVDesignSystem.Colors.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(DVDesignSystem.Colors.divider, lineWidth: 1)
            )
            
            mapLegend
        }
        .background(DVDesignSystem.Components.card())
    }
    
    private var mapOverlays: some View {
        ZStack {
            // Example points of interest for different map views
            // Would be data-driven in a real app
            switch selectedView {
            case .overview:
                Circle()
                    .fill(DVDesignSystem.Colors.orange)
                    .frame(width: 12, height: 12)
                    .position(x: 120, y: 150)
                
                Circle()
                    .fill(DVDesignSystem.Colors.teal)
                    .frame(width: 12, height: 12)
                    .position(x: 200, y: 100)
                
                Circle()
                    .fill(DVDesignSystem.Colors.yellow)
                    .frame(width: 12, height: 12)
                    .position(x: 180, y: 200)
                
            case .structures:
                // Structure points
                ForEach(0..<5) { i in
                    Circle()
                        .fill(DVDesignSystem.Colors.teal)
                        .frame(width: 10, height: 10)
                        .position(
                            x: CGFloat.random(in: 100...250),
                            y: CGFloat.random(in: 80...220)
                        )
                }
                
            case .terrain:
                // Terrain highlights
                RoundedRectangle(cornerRadius: 8)
                    .fill(DVDesignSystem.Colors.orange.opacity(0.3))
                    .frame(width: 80, height: 40)
                    .position(x: 150, y: 100)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(DVDesignSystem.Colors.teal.opacity(0.3))
                    .frame(width: 60, height: 50)
                    .position(x: 220, y: 180)
            }
        }
    }
    
    private var mapLegend: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Map Legend")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(DVDesignSystem.Colors.text)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            Divider()
                .padding(.horizontal, 16)
            
            ForEach(getLegendItems(), id: \.title) { item in
                HStack(spacing: 12) {
                    Circle()
                        .fill(item.color)
                        .frame(width: 10, height: 10)
                    
                    Text(item.title)
                        .font(.system(size: 14))
                        .foregroundColor(DVDesignSystem.Colors.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            .padding(.bottom, 16)
        }
    }
    
    private var controlPanel: some View {
        VStack(spacing: 16) {
            Toggle(isOn: $showPointsOfInterest) {
                Text("Show Points of Interest")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DVDesignSystem.Colors.text)
            }
            .toggleStyle(SwitchToggleStyle(tint: DVDesignSystem.Colors.teal))
            
            HStack {
                Text("Map Scale: \(Int(mapScale * 100))%")
                    .font(.system(size: 14))
                    .foregroundColor(DVDesignSystem.Colors.textSecondary)
                
                Spacer()
                
                Button {
                    withAnimation {
                        mapScale = 1.0
                    }
                } label: {
                    Text("Reset")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DVDesignSystem.Colors.text)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(DVDesignSystem.Colors.yellow.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(DVDesignSystem.Components.card())
    }
    
    private func getLegendItems() -> [(title: String, color: Color)] {
        switch selectedView {
        case .overview:
            return [
                ("Campus Buildings", DVDesignSystem.Colors.orange),
                ("DV Structures", DVDesignSystem.Colors.teal),
                ("Activities", DVDesignSystem.Colors.yellow)
            ]
        case .structures:
            return [
                ("Participant Shelters", DVDesignSystem.Colors.teal),
                ("Permanent Structures", DVDesignSystem.Colors.orange)
            ]
        case .terrain:
            return [
                ("Steep Areas", DVDesignSystem.Colors.orange.opacity(0.8)),
                ("Shaded Areas", DVDesignSystem.Colors.teal.opacity(0.8))
            ]
        }
    }
}

enum MapViewType: String, CaseIterable {
    case overview, structures, terrain
    
    var displayName: String {
        switch self {
        case .overview: return "Overview"
        case .structures: return "Structures"
        case .terrain: return "Terrain"
        }
    }
    
    var imageName: String {
        "DVMap" + rawValue.capitalized
    }
}

struct DVMap_Previews: PreviewProvider {
    static var previews: some View {
        DVMap()
            .nexusStyle()
    }
}
