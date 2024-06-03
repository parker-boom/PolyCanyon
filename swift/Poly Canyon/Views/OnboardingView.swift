// MARK: Overview
/*
    OnboardingView.swift

    This file defines the OnboardingView struct, which presents a multi-page onboarding experience.

    Key Components:
    - isNewOnboardingCompleted: Tracks onboarding completion.
    - currentPage: Manages the current page index.
    - totalPages: Total number of onboarding pages.

    Functionality:
    - Displays a series of images in a TabView.
    - Tapping the last image marks onboarding as complete.
*/

// MARK: Code
import SwiftUI

struct OnboardingView: View {
    // Variables
    @Binding var isNewOnboardingCompleted: Bool
    @State private var currentPage = 0
    private let totalPages = 4
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()

                // All the pages
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

// MARK: Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isNewOnboardingCompleted: .constant(false))
    }
}
