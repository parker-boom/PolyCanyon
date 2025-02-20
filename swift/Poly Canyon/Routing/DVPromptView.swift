// DVDecisionPromptView.swift
import SwiftUI

struct DVPromptView: View {
    /// Callback to return the user's decision: true for DV mode, false for Poly Canyon.
    let decisionHandler: (Bool) -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    VStack(spacing: 0) {
                        Image("DVLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 280)
                            .frame(height: 120)
                            .padding(.bottom, 32)
                        
                        Text("Design Village Weekend")
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundColor(Color(hex: "1a1a1a"))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        
                        Text("Are you here celebrating?")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "333333"))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 62)
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                decisionHandler(false)
                            }) {
                                Text("No")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "666666"))
                                    .frame(minWidth: 100)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 32)
                                    .background(Color(hex: "f5f5f5"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "e0e0e0"), lineWidth: 1)
                                    )
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {
                                decisionHandler(true)
                            }) {
                                Text("Yes")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 100)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 32)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                        
                        Text("Selecting yes will transform your app,\n but you can switch back anytime")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "666666"))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: 480)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                    
                    Spacer(minLength: 0)
                }
                .frame(minHeight: UIScreen.main.bounds.height)
            }
        }
    }
}

struct DVPromptView_Previews: PreviewProvider {
    static var previews: some View {
        DVPromptView { decision in
            print("User decision: \(decision)")
        }
    }
}
