// MARK: - Overview
/*
    StructPopUp.swift

    This file defines the StructPopUp structure, which displays detailed information about a selected structure in a popup view.

    Key Components:
    - Displays the structure's image, close-up, number, title, and year.
    - Allows users to swipe between images and dismiss the view.
    - Shows a description or a placeholder message if the description is not available.
    - Provides a close button to dismiss the popup.

    Functionality:
    - Utilizes gesture recognition to swipe between images or dismiss the view by swiping down.
    - Adjusts the UI elements based on the dark mode setting.
*/



// MARK: - Code
import SwiftUI

struct StructPopUp: View {
    // MARK: - Properties
    
    let structure: Structure?
    @State private var selectedImageIndex = 0
    @Environment(\.presentationMode) var presentationMode
    @Binding var isDarkMode: Bool
    var onDismiss: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        if let structure = structure {
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        // Blurred background image
                        Image(selectedImageIndex == 0 ? structure.imageName : structure.closeUp)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.width * 1.5)
                            .blur(radius: 10)
                        
                        // Main image
                        Image(selectedImageIndex == 0 ? structure.imageName : structure.closeUp)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width, height: geometry.size.width * 1.5)
                            .clipped()
                        
                        VStack {
                            HStack {
                                // Structure number in the top left corner
                                Text("\(structure.number)")
                                    .font(.system(size: 35))
                                    .foregroundColor(.white)
                                    .shadow(color: Color.black.opacity(0.7), radius: 6, x: 0, y: 2)
                                    .shadow(color: Color.black.opacity(0.9), radius: 10, x: 0, y: 2)
                                    .shadow(color: Color.white.opacity(0.5), radius: 12, x: 0, y: 2)
                                    .padding(.leading, 10)
                                    .frame(width: 55)
                                
                                Spacer()
                                
                                // Structure title and year at the top, centered
                                VStack {
                                    Text(structure.title)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(color: Color.black.opacity(0.7), radius: 6, x: 0, y: 2)
                                        .shadow(color: Color.black.opacity(0.9), radius: 10, x: 0, y: 2)
                                        .shadow(color: Color.white.opacity(0.5), radius: 12, x: 0, y: 2)
                                        .multilineTextAlignment(.center)
                                    
                                    if !(structure.year == "xxxx") {
                                        Text(structure.year)
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                            .shadow(color: Color.black.opacity(0.7), radius: 6, x: 0, y: 2)
                                            .shadow(color: Color.black.opacity(0.9), radius: 10, x: 0, y: 2)
                                            .shadow(color: Color.white.opacity(0.5), radius: 12, x: 0, y: 2)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                
                                Spacer()
                                
                                // "X" button with translucent circle in the top right corner
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                    onDismiss()
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(width: 30, height: 30)
                                        
                                        Image(systemName: "xmark")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }
                                .frame(width: 50)
                                .shadow(color: Color.black.opacity(0.7), radius: 6, x: 0, y: 2)
                                .shadow(color: Color.black.opacity(0.9), radius: 10, x: 0, y: 2)
                                .shadow(color: Color.white.opacity(0.5), radius: 12, x: 0, y: 2)
                                .padding(.trailing, 10)
                            }
                            
                            Spacer()
                            
                            // Image indicator dots
                            HStack {
                                Circle()
                                    .fill(selectedImageIndex == 0 ? Color.white : Color.gray)
                                    .frame(width: selectedImageIndex == 0 ? 12 : 8, height: selectedImageIndex == 0 ? 12 : 8)
                                Circle()
                                    .fill(selectedImageIndex == 1 ? Color.white : Color.gray)
                                    .frame(width: selectedImageIndex == 1 ? 12 : 8, height: selectedImageIndex == 1 ? 12 : 8)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .frame(height: geometry.size.width * 1.5)
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width < 0 {
                                    // Swiped left
                                    selectedImageIndex = 1
                                } else if value.translation.width > 0 {
                                    // Swiped right
                                    selectedImageIndex = 0
                                }
                                if value.translation.height > 100 {
                                    // User swiped down, dismiss the view
                                    presentationMode.wrappedValue.dismiss()
                                    onDismiss()
                                }
                            }
                    )
                    // Hide if no description
                    if (structure.description == "iii") {
                        Text("More information coming soon!")
                            .font(.system(size: 26))
                            .foregroundColor(isDarkMode ? .white : .black)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                            .padding(.horizontal, 16)
                    } else {
                        Text(structure.description)
                            .font(.system(size: 18))
                            .foregroundColor(isDarkMode ? .white : .black)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                            .padding(.horizontal, 16)
                    }
                    
                    
                    Spacer()
                }
                
            }
            .background(isDarkMode ? Color.black : Color.white)

        } else {
            Text("How did you get here? :0")
        }
    }
}


