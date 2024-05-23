import SwiftUI

struct OnboardingView: View {
    @Binding var isNewOnboardingCompleted: Bool
    @State private var currentPage = 0
    private let totalPages = 4
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Image("\(index + 1)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width * 1, height: UIScreen.main.bounds.height, alignment: .bottom)
                            .clipped()
                            .onTapGesture {
                                if index == totalPages - 1 {
                                    isNewOnboardingCompleted = true
                                }
                            }
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isNewOnboardingCompleted: .constant(false))
    }
}
