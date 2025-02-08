// DVDecisionPromptView.swift
import SwiftUI

struct DVPromptView: View {
    /// Callback to return the user's decision: true for DV mode, false for Poly Canyon.
    let decisionHandler: (Bool) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Limited Time Event!")
                .font(.title)
                .padding(.top, 40)
            Text("Design Village is live this weekend. Would you like to check it out?")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            HStack(spacing: 40) {
                Button(action: {
                    decisionHandler(false)
                }) {
                    Text("No")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                Button(action: {
                    decisionHandler(true)
                }) {
                    Text("Yes")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 40)
        }
        .padding()
    }
}

struct DVPromptView_Previews: PreviewProvider {
    static var previews: some View {
        DVPromptView { decision in
            print("User decision: \(decision)")
        }
    }
}
