import SwiftUI

struct DVAppView: View {
    @AppStorage("DVOnboardingComplete") var onboardingComplete: Bool = false

    var body: some View {
        NavigationView {
            if onboardingComplete {
                DVMain()
            } else {
                DVOnboarding()
            }
        }
    }
}

struct DVAppView_Previews: PreviewProvider {
    static var previews: some View {
        DVAppView()
    }
}
