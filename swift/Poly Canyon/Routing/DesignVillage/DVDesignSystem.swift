import SwiftUI

// MARK: - Design System

struct DVDesignSystem {
    // MARK: - Color Scheme
    enum ColorScheme {
        case light
        case dark
        
        var swiftUIColorScheme: SwiftUI.ColorScheme {
            switch self {
            case .light: return .light
            case .dark: return .dark
            }
        }
        
        static func current(forceLight: Bool = false, forceDark: Bool = false) -> ColorScheme {
            if forceLight {
                return .light
            } else if forceDark {
                return .dark
            } else {
                // Auto mode - could be based on sunset time
                // For now using a simple time check (7:00 PM to 6:00 AM = dark mode)
                let hour = Calendar.current.component(.hour, from: Date())
                return (hour >= 19 || hour < 6) ? .dark : .light
            }
        }
    }
    
    // MARK: - Colors
    struct Colors {
        static var scheme: ColorScheme = .light
        
        // Base colors
        static var background: Color {
            scheme == .light ? Color(hex: "f8eed4") : Color.black
        }
        
        static var surface: Color {
            scheme == .light ? Color.white : Color(red: 0.12, green: 0.12, blue: 0.12)
        }
        
        static var text: Color {
            scheme == .light ? Color(hex: "060505") : Color.white
        }
        
        static var textSecondary: Color {
            scheme == .light ? Color(hex: "060505").opacity(0.7) : Color(white: 0.8)
        }
        
        // Accent colors
        static let yellow = Color(hex: "f5ba33")
        static let orange = Color(hex: "e85034")
        static let teal = Color(hex: "6bbab9")
        
        // Additional dark mode accent color
        static let red = Color(red: 0.9, green: 0.25, blue: 0.2)
        
        // Functional colors
        static var divider: Color {
            scheme == .light ? Color(hex: "060505").opacity(0.15) : Color.white.opacity(0.15)
        }
        
        static var overlay: Color {
            scheme == .light ? Color.black.opacity(0.05) : Color.black.opacity(0.5)
        }
        
        static var shadowColor: Color {
            scheme == .light ? Color.black.opacity(0.1) : yellow.opacity(0.3)
        }
    }
    
    // MARK: - Typography
    struct Typography {
        // Heading styles
        static func title() -> some View {
            Text("")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(Colors.text)
                .tracking(1.5)
        }
        
        static func heading1() -> some View {
            Text("")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Colors.text)
                .tracking(1)
        }
        
        static func heading2() -> some View {
            Text("")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Colors.text)
                .tracking(0.5)
        }
        
        static func heading3() -> some View {
            Text("")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Colors.text)
        }
        
        // Body styles
        static func body() -> some View {
            Text("")
                .font(.system(size: 16))
                .foregroundColor(Colors.textSecondary)
                .lineSpacing(5)
        }
        
        static func caption() -> some View {
            Text("")
                .font(.system(size: 14))
                .foregroundColor(Colors.textSecondary)
        }
    }
    
    // MARK: - Shapes & Effects
    struct Effects {
        static func cardShadow() -> some View {
            Rectangle()
                .fill(Color.clear)
                .shadow(color: Colors.shadowColor, radius: 15, x: 0, y: 4)
        }
        
        static func accentLine() -> some View {
            LinearGradient(
                colors: [Colors.yellow, Colors.teal, Colors.orange],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 3)
        }
    }
    
    // MARK: - Components
    struct Components {
        static func card() -> some View {
            RoundedRectangle(cornerRadius: 12)
                .fill(Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Colors.divider, lineWidth: 1)
                )
                .shadow(color: Colors.shadowColor, radius: 6, x: 0, y: 2)
        }
        
        static func button(isSelected: Bool = false) -> some View {
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Colors.yellow)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Colors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Colors.divider, lineWidth: 1)
                        )
                }
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    func nexusStyle(scheme: DVDesignSystem.ColorScheme = .light) -> some View {
        DVDesignSystem.Colors.scheme = scheme
        return self
            .background(DVDesignSystem.Colors.background)
            .foregroundColor(DVDesignSystem.Colors.text)
            .preferredColorScheme(scheme.swiftUIColorScheme)
    }
}


// MARK: - Style Preview

struct DVDesignSystemPreview: View {
    @State private var showingLightMode: Bool = true
    
    var body: some View {
        VStack {
            HStack {
                Text("Preview Mode")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showingLightMode.toggle()
                    DVDesignSystem.Colors.scheme = showingLightMode ? .light : .dark
                }) {
                    Text(showingLightMode ? "Switch to Dark Mode" : "Switch to Light Mode")
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(showingLightMode ? 
                                    Color.black.opacity(0.1) : 
                                    Color.white.opacity(0.2))
                        )
                        .foregroundColor(showingLightMode ? 
                            DVDesignSystem.Colors.text : 
                            DVDesignSystem.Colors.text)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            ScrollView {
                VStack(spacing: 32) {
                    title
                    colors
                    typography
                    components
                    tabBarPreview
                    infoCardPreview
                }
                .padding(24)
            }
        }
        .nexusStyle(scheme: showingLightMode ? .light : .dark)
        .animation(.easeInOut, value: showingLightMode)
    }
    
    private var title: some View {
        VStack(spacing: 8) {
            Text("NEXUS")
                .font(.system(size: 48, weight: .black))
                .tracking(8)
                .foregroundColor(DVDesignSystem.Colors.text)
            
            DVDesignSystem.Effects.accentLine()
                .frame(width: 200)
            
            Text("DESIGN VILLAGE")
                .font(.system(size: 16, weight: .medium))
                .tracking(4)
                .foregroundColor(DVDesignSystem.Colors.textSecondary)
        }
    }
    
    private var colors: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Color Palette")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(DVDesignSystem.Colors.text)
            
            HStack(spacing: 12) {
                colorSwatch(color: DVDesignSystem.Colors.yellow, name: "Yellow")
                colorSwatch(color: DVDesignSystem.Colors.orange, name: "Orange")
                colorSwatch(color: DVDesignSystem.Colors.teal, name: "Teal")
            }
            
            HStack(spacing: 12) {
                colorSwatch(color: DVDesignSystem.Colors.background, name: "Background")
                colorSwatch(color: DVDesignSystem.Colors.surface, name: "Surface")
                colorSwatch(color: DVDesignSystem.Colors.text, name: "Text")
                colorSwatch(color: DVDesignSystem.Colors.textSecondary, name: "Text Secondary")
            }
        }
    }
    
    private func colorSwatch(color: Color, name: String) -> some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(color)
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(DVDesignSystem.Colors.divider, lineWidth: 1)
                )
            
            Text(name)
                .font(.system(size: 12))
                .foregroundColor(DVDesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var typography: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Typography")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(DVDesignSystem.Colors.text)
            
            Group {
                Text("Title Style")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(DVDesignSystem.Colors.text)
                    .tracking(1.5)
                
                Text("Heading 1 Style")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(DVDesignSystem.Colors.text)
                    .tracking(1)
                
                Text("Heading 2 Style")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(DVDesignSystem.Colors.text)
                    .tracking(0.5)
                
                Text("Heading 3 Style")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DVDesignSystem.Colors.text)
                
                Text("Body text style with longer content to show line height and spacing. Design Village is an architecture event where students build temporary structures in Poly Canyon. The theme for this year is Nexus.")
                    .font(.system(size: 16))
                    .foregroundColor(DVDesignSystem.Colors.textSecondary)
                    .lineSpacing(5)
                
                Text("Caption Style")
                    .font(.system(size: 14))
                    .foregroundColor(DVDesignSystem.Colors.textSecondary)
            }
            .padding(.vertical, 6)
        }
    }
    
    private var components: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Components")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(DVDesignSystem.Colors.text)
            
            HStack(spacing: 20) {
                ZStack {
                    DVDesignSystem.Components.button(isSelected: false)
                        .frame(height: 50)
                    
                    Text("Normal Button")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DVDesignSystem.Colors.text)
                }
                
                ZStack {
                    DVDesignSystem.Components.button(isSelected: true)
                        .frame(height: 50)
                    
                    Text("Selected Button")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DVDesignSystem.Colors.scheme == .light ? 
                            Color(hex: "060505") : Color.black)
                }
            }
            .padding(.bottom, 20)
            
            ZStack {
                DVDesignSystem.Components.card()
                    .frame(height: 120)
                
                VStack(alignment: .leading) {
                    Text("Card Component")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(DVDesignSystem.Colors.text)
                    
                    Spacer()
                    
                    DVDesignSystem.Effects.accentLine()
                }
                .padding(16)
            }
        }
    }
    
    private var tabBarPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tab Bar")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(DVDesignSystem.Colors.text)
            
            VStack(spacing: 0) {
                Rectangle()
                    .fill(DVDesignSystem.Colors.divider)
                    .frame(height: 1)
                
                HStack(spacing: 0) {
                    ForEach(0..<5) { index in
                        Image(systemName: ["info.circle.fill", "map.fill", "clock.fill", "list.bullet.clipboard.fill", "gearshape.fill"][index])
                            .font(.system(size: 24))
                            .foregroundStyle(index == 1 ? 
                                DVDesignSystem.Colors.yellow : 
                                DVDesignSystem.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .scaleEffect(index == 1 ? 1.15 : 1.0)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .background(DVDesignSystem.Colors.surface)
            }
        }
    }
    
    private var infoCardPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Info Card Example")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(DVDesignSystem.Colors.text)
            
            ZStack {
                DVDesignSystem.Components.card()
                    .frame(height: 200)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("What Is Design Village?")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(DVDesignSystem.Colors.text)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DVDesignSystem.Colors.textSecondary)
                            .rotationEffect(.degrees(-180))
                    }
                    
                    Text("Design Village is Cal Poly's signature hands-on design-build competition, where first-year architecture students and visiting college teams construct temporary shelters in Poly Canyon.")
                        .font(.system(size: 16))
                        .foregroundColor(DVDesignSystem.Colors.textSecondary)
                        .lineSpacing(4)
                    
                    Spacer()
                    
                    Text("Theme: Nexus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DVDesignSystem.Colors.yellow)
                }
                .padding(16)
            }
        }
    }
}

// MARK: - Preview Provider

struct DVDesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DVDesignSystemPreview()
                .previewDisplayName("Interactive Preview")
            
            DVDesignSystemPreview()
                .nexusStyle(scheme: .light)
                .previewDisplayName("Light Mode")
            
            DVDesignSystemPreview()
                .nexusStyle(scheme: .dark)
                .previewDisplayName("Dark Mode")
        }
    }
} 
