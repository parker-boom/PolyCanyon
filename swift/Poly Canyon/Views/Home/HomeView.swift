import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Spacer()
            Button {
                appState.activeFullScreenView = .settings
            } label: {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            .padding()
            Spacer()
            Button {
                appState.activeFullScreenView = .tinderMode
            } label: {
                Image(systemName: "heart.fill")
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
