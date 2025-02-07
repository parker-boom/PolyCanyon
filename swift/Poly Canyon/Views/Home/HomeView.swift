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
            .padding()
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
