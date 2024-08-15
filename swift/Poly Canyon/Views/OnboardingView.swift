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
                ZStack {
                    TabView(selection: $currentPage) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Image("\(index + 1)")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .bottom)
                                .clipped()
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                }
                .contentShape(Rectangle()) // Makes the entire area tappable
                .onTapGesture {
                    if currentPage < totalPages - 1 {
                        currentPage += 1
                    } else {
                        isNewOnboardingCompleted = true
                    }
                }
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
