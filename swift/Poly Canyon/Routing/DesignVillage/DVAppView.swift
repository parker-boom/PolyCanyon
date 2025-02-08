// DVAppView.swift
import SwiftUI

struct DVAppView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Design Village!")
                    .font(.largeTitle)
                    .padding()
                // Additional static content for Design Village goes here.
                Spacer()
            }
            .navigationTitle("Design Village")
        }
    }
}

struct DVAppView_Previews: PreviewProvider {
    static var previews: some View {
        DVAppView()
    }
}
