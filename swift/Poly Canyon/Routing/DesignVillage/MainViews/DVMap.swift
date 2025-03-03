import SwiftUI

struct DVMap: View {
    var body: some View {
        ScrollView {
            VStack {
                Color.gray.opacity(0.2)
                    .frame(height: 400)
                    .overlay(
                        Text("Map Image")
                            .foregroundColor(.gray)
                    )
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 40)
        }
        .background(DVDesignSystem.Colors.background)
    }
}