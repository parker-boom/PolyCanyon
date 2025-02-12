import SwiftUI

struct DVAppView: View {
    @AppStorage("DVOnboardingComplete") var onboardingComplete: Bool = false
    @Binding var designVillageMode: Bool
    
    var body: some View {
        NavigationView {
            if onboardingComplete {
                DVMain(designVillageMode: $designVillageMode)
            } else {
                DVOnboarding()
            }
        }
    }
}

struct DVAppView_Previews: PreviewProvider {
    static var previews: some View {
        DVAppView(designVillageMode: .constant(true))
    }
}
