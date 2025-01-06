import SwiftUI

struct VisitNotificationView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    let structure: Structure
    
    var body: some View {
        ZStack {
            // Semi-opaque background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    // Tap outside to dismiss
                    dataStore.lastVisitedStructure = nil
                }
            
            // Popup content
            VStack(spacing: 12) {
                Text("Just Visited!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Image(structure.mainPhoto)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .cornerRadius(10)
                
                Text(structure.title)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Close button
                Button(action: {
                    dataStore.lastVisitedStructure = nil
                }) {
                    Text("Close")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal, 40)
            }
            .padding()
            .background(appState.isDarkMode ? Color.black : Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding(.horizontal, 20)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: dataStore.lastVisitedStructure)
    }
}
