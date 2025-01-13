import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Home!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
