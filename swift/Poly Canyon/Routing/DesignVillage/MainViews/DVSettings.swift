import SwiftUI

struct DVSettings: View {
    @Binding var designVillageMode: Bool
    @State private var showSwitchConfirmation = false
    @State private var showRulesPopup = false
    @State private var showResetConfirmation = false
    @State private var isChangeModeButtonPressed = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                exploreButton
                
                Divider()
                    .background(DVDesignSystem.Colors.divider)
                    .padding(.horizontal)
                
                socialSection
                creditsSection
                
                resetButton
            }
            .padding(.top, 15)
            .padding(.bottom, 40)
        }
        .onAppear {
            print("🔍 [DVSettings] onAppear with designVillageMode: \(designVillageMode)")
        }
        .sheet(isPresented: $showRulesPopup) {
            rulesPopupContent
        }
        .alert("Switch to Poly Canyon?", isPresented: $showSwitchConfirmation) {
            Button("Cancel", role: .cancel) { 
                print("❌ [DVSettings] Switch to PC canceled")
            }
            Button("Switch") {
                print("✅ [DVSettings] User confirmed switch to PC")
                print("⏩ [DVSettings] Before switch - designVillageMode: \(designVillageMode)")
                
                // First set the UserDefaults value to ensure it's saved
                UserDefaults.standard.set(false, forKey: "designVillageModeOverride")
                print("💾 [DVSettings] Updated UserDefaults to false")
                
                // Then update the binding
                designVillageMode = false
                
                print("⏩ [DVSettings] After switch - designVillageMode: \(designVillageMode)")
                
                // Force a UI update
                DispatchQueue.main.async {
                    print("🔄 [DVSettings] Dispatching async UI update")
                    NotificationCenter.default.post(name: Notification.Name("ModeSwitched"), object: nil)
                }
            }
        } message: {
            Text("Are you sure you want to switch? This will make your app the Poly Canyon experience. You can switch back in settings any time.")
        }
        .alert("Reset Onboarding?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                UserDefaults.standard.set(false, forKey: "DVOnboardingComplete")
                UserDefaults.standard.set("visitor", forKey: "DVUserRole")
            }
        } message: {
            Text("This will reset your onboarding progress and role selection. You'll need to go through the onboarding process again.")
        }
    }
    
    private var exploreButton: some View {
        Button {
            print("👆 [DVSettings] Explore button tapped")
            showSwitchConfirmation = true
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottom) {
                    Image("PCOverview")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    DVDesignSystem.Colors.text.opacity(0.5)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Explore the Canyon")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(DVDesignSystem.Colors.text)
                        
                        Text("Switch to the Poly Canyon experience")
                            .font(.system(size: 14))
                            .foregroundColor(DVDesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(
                            DVDesignSystem.Colors.yellow
                        )
                }
                .padding()
            }
            .background(DVDesignSystem.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                DVDesignSystem.Colors.teal,
                                DVDesignSystem.Colors.yellow,
                                DVDesignSystem.Colors.orange
                            ],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 6, x: 0, y: 3)
            .scaleEffect(isChangeModeButtonPressed ? 0.98 : 1.0)
            .pressAction {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    isChangeModeButtonPressed = true
                }
            } onRelease: {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    isChangeModeButtonPressed = false
                }
            }
        }
        .pressAction {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                isChangeModeButtonPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                isChangeModeButtonPressed = false
            }
        }
        .padding(.horizontal)
    }
    
    private var socialSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            DVTitleWithShadow(
                text: "Connect With Us",
                font: .system(size: 20, weight: .bold)
            )
            .padding(.horizontal)
            
            HStack(spacing: 16) {
                Link(destination: URL(string: "https://www.instagram.com/designvillage.dwg/")!) {
                    HStack {
                        Image("InstaIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text("Instagram")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(DVDesignSystem.Colors.text)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(DVDesignSystem.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        DVDesignSystem.Colors.orange,
                                        DVDesignSystem.Colors.teal
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 4, x: 0, y: 2)
                }
                
                Link(destination: URL(string: "https://cpdesignvillage.wixstudio.com/designvillage/about")!) {
                    HStack {
                        Image(systemName: "link")
                            .font(.system(size: 20))
                        
                        Text("Website")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(DVDesignSystem.Colors.text)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(DVDesignSystem.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        DVDesignSystem.Colors.teal,
                                        DVDesignSystem.Colors.orange
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var creditsSection: some View {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                Image("CAEDLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                
                Image("DVLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
            }
            
            VStack(spacing: 8) {
                DVTitleWithShadow(
                    text: "Developed by Parker Jones",
                    font: .system(size: 16, weight: .medium)
                )
                
                Text("For CAED & Design Village")
                    .font(.system(size: 14))
                    .foregroundColor(DVDesignSystem.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(DVDesignSystem.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            DVDesignSystem.Colors.yellow,
                            DVDesignSystem.Colors.orange,
                            DVDesignSystem.Colors.yellow
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private var rulesPopupContent: some View {
        VStack {
            DVTitleWithShadow(
                text: "Rules",
                font: .system(size: 28, weight: .bold)
            )
            .padding(.top, 40)
            
            Spacer()
            
            Button {
                showRulesPopup = false
            } label: {
                Text("Close")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DVDesignSystem.Colors.text)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DVDesignSystem.Colors.yellow.opacity(0.2))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        DVDesignSystem.Colors.orange,
                                        DVDesignSystem.Colors.teal
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .padding()
            }
        }
        .nexusStyle()
    }
    
    private var resetButton: some View {
        Button {
            showResetConfirmation = true
        } label: {
            HStack {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 20))
                
                Text("Reset Onboarding")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(DVDesignSystem.Colors.red)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(DVDesignSystem.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        DVDesignSystem.Colors.red.opacity(0.7),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}

struct DVSettings_Previews: PreviewProvider {
    static var previews: some View {
        DVSettings(designVillageMode: .constant(true))
            .nexusStyle()
    }
}
