import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Button {
                appState.activeFullScreenView = .settings
            } label: {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            .padding()
            
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
