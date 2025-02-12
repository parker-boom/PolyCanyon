import SwiftUI

struct DVSettings: View {
    @Binding var designVillageMode: Bool
    @State private var showSwitchConfirmation = false
    @State private var showRulesPopup = false
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(spacing: 24) {
                    exploreButton
                    rulesButton
                    
                    Divider()
                        .padding(.horizontal)
                    
                    socialSection
                    creditsSection
                }
                .padding(.top, 15)
                .padding(.bottom, 40)
            }
        }
        .background(Color(white: 0.98))
        .sheet(isPresented: $showRulesPopup) {
            rulesPopupContent
        }
        .alert("Switch to Poly Canyon?", isPresented: $showSwitchConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Switch") {
                designVillageMode = false
                UserDefaults.standard.set(false, forKey: "designVillageModeOverride")
            }
        } message: {
            Text("Are you sure you want to switch? This will make your app the Poly Canyon experience. You can switch back in settings any time.")
        }
    }
    
    private var header: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .ignoresSafeArea(edges: .top)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
            
            HStack {
                Text("Settings")
                    .font(.system(size: 32, weight: .bold))
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.black, Color.gray],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 5)
        }
        .frame(height: 50)
        .padding(.bottom, 5)
    }
    
    private var exploreButton: some View {
        Button {
            showSwitchConfirmation = true
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Image("M-25")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipped()
                
                HStack {
                    Text("Explore the Canyon")
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .semibold))
                }
                .foregroundColor(.black)
                .padding()
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
            .padding(.horizontal)
        }
    }
    
    private var rulesButton: some View {
        Button {
            showRulesPopup = true
        } label: {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 20, weight: .semibold))
                Text("Revisit the Rules")
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.black)
            .padding()
            .frame(height: 72)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
        }
    }
    
    private var socialSection: some View {
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
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
            
            Link(destination: URL(string: "https://cpdesignvillage.wixstudio.com/designvillage/about")!) {
                HStack {
                    Image(systemName: "link")
                        .font(.system(size: 20))
                    Text("Website")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, -8)
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
                Text("Developed by Parker Jones")
                    .font(.system(size: 16, weight: .medium))
                
                Text("For CAED & Design Village")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    private var rulesPopupContent: some View {
        VStack {
            Text("Rules")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 40)
            
            Spacer()
            
            Button {
                showRulesPopup = false
            } label: {
                Text("Close")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding()
            }
        }
    }
}

struct DVSettings_Previews: PreviewProvider {
    static var previews: some View {
        DVSettings(designVillageMode: .constant(true))
    }
}
