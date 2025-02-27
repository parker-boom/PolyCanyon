import SwiftUI


struct DVAppView: View {
    @AppStorage("DVOnboardingComplete") var onboardingComplete: Bool = false
    @AppStorage("DVUserRole") var userRole: DVRole = .visitor
    @Binding var designVillageMode: Bool
    
    var body: some View {
        NavigationView {
            if onboardingComplete {
                DVMain(designVillageMode: $designVillageMode, userRole: $userRole)
            } else {
                DVOnboarding(userRole: $userRole)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.light)
    }
}

struct DVAppView_Previews: PreviewProvider {
    static var previews: some View {
        DVAppView(designVillageMode: .constant(true))
    }
}
