import SwiftUI

struct OnboardingView: View {
    @Binding var isFirstLaunch: Bool
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("OnboardingPopUp")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width - 40) // Adjust the frame size as needed
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        isFirstLaunch = false
                    }
            }
        }
        .onTapGesture {
            isFirstLaunch = false
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isFirstLaunch: .constant(true))
    }
}
