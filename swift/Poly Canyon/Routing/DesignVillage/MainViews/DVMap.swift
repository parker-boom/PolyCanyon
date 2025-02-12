import SwiftUI

struct DVMap: View {
    var body: some View {
        VStack(spacing: 0) {
            header
            
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
        }
        .background(Color(white: 0.98))
    }
    
    private var header: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .ignoresSafeArea(edges: .top)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
            
            HStack {
                Text("Map")
                    .font(.system(size: 32, weight: .bold))
                Image(systemName: "map.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.black, Color.gray],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 5)
        }
        .frame(height: 50)
        .padding(.bottom, 5)
    }
}
