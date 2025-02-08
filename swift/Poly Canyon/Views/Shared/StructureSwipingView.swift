/*
 StructureSwipingView implements a Tinder-style card swiping interface for rating structures. It manages 
 the rating flow with swipe gestures and like/dislike buttons, tracks progress, and shows a completion 
 view when finished. The view persists rating progress and adapts to the app theme. It provides haptic 
 feedback and smooth animations for card transitions.
*/

import SwiftUI

// MARK: - StructureSwipingView (Top-Level Container)

struct RatingsView: View {
    // MARK: - Environment
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    // MARK: - State
    @State private var currentIndex: Int = -1
    @State private var offset: CGSize = .zero
    @State private var color: Color = .black
    @State private var likedCount = 0
    @State private var hasFinishedRating = false
    
    // MARK: - Constants
    private let swipeThreshold: CGFloat = 50.0
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundColor
            
            VStack {
                if currentIndex == -1 {
                    // 
                    StartingView()
                } else if currentIndex < dataStore.structures.count {
                    RatingContentView(
                        currentIndex: $currentIndex,
                        offset: $offset,
                        color: $color,
                        likedCount: $likedCount,
                        swipeThreshold: swipeThreshold
                    )
                    .padding(.top, 50)
                } else {
                    CompletionView(
                        likedCount: $likedCount,
                        onRestart: restartRating,
                        onExit: { appState.activeFullScreenView = nil }
                    )
                }
            }
        }
        .onChange(of: appState.tinderModeStructureNum) { newVal in
            currentIndex = newVal
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            initializeCurrentIndex()
            updateLikedCount()
        }
    }
    
    // MARK: - Private Computed Vars / Helpers
    
    /// Background color based on dark mode.
    private var backgroundColor: Color {
        appState.isDarkMode ? .black : .white
    }
    
    /// Updates the count of liked structures.
    private func updateLikedCount() {
        likedCount = dataStore.structures.filter { $0.isLiked }.count
    }

    /// Initializes the current index based on the app state.
    private func initializeCurrentIndex() {
        currentIndex = appState.tinderModeStructureNum
    }
    
    /// Resets the rating flow so the user can start over.
    private func restartRating() {
        currentIndex = 0
        saveProgress()
        dataStore.resetLikes()
        updateLikedCount()
    }
    
    /// Saves current progress in UserDefaults.
    private func saveProgress() {
        appState.tinderModeStructureNum = currentIndex
    }
}

// MARK: - RatingContentView (Subview)

/// The main rating UI: a title, progress text, swipeable cards, plus like/dislike buttons and an exit button.
private struct RatingContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var scale: CGFloat = 1.0
    
    @Binding var currentIndex: Int
    @Binding var offset: CGSize
    @Binding var color: Color
    @Binding var likedCount: Int
    
    let swipeThreshold: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            // Title section - positioned from top
            VStack(spacing: 5) {
                Text("Rate Structures")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black.opacity(0.8))
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)

                Text(progressText)
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.8))
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
            }
            .frame(maxWidth: UIScreen.main.bounds.width - 40)
            .padding(.vertical, 15)
            .glassBackground(cornerRadius: 20)
            .shadow(color: .black.opacity(0.65), radius: 7, x: 0, y: 0)
            .padding(.top, 20) // Distance from top safe area

            // Card section with reduced height
            ZStack {
                ForEach(dataStore.structures.indices, id: \.self) { index in
                    if index >= currentIndex && index <= min(currentIndex + 2, dataStore.structures.count - 1) {
                        cardView(for: dataStore.structures[index])
                            .offset(index == currentIndex ? offset : .zero)
                            .rotationEffect(.degrees(Double(index == currentIndex ? offset.width / 10 : 0)))
                            .zIndex(index == currentIndex ? 1 : 0) 
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        if index == currentIndex {
                                            offset = gesture.translation
                                            withAnimation {
                                                color = offset.width > 0 ? .green : .red
                                            }
                                        }
                                    }
                                    .onEnded { _ in
                                        if index == currentIndex {
                                            withAnimation {
                                                swipeCard(width: offset.width)
                                                color = .black
                                            }
                                        }
                                    }
                            )
                            .zIndex(Double(dataStore.structures.count - index)) // Ensure the currentIndex card is on top
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 25) // Spacing around card section

            // Like/Dislike buttons
            HStack(spacing: 20) {
                // Dislike Button
                Button(action: { swipeCard(width: -500) }) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                        Text("Not for me")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Material.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.red.opacity(0.7))
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.5),
                                        .red.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(
                        color: Color.red.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                
                // Like Button
                Button(action: { swipeCard(width: 500) }) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 24))
                        Text("Favorite")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Material.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.green.opacity(0.7))
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.5),
                                        .green.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(
                        color: Color.green.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 15) // Space from cards to buttons

            Spacer() // Dynamic space

            // Exit button - positioned from bottom
            exitButton
                .padding(.bottom, 30) // Distance from bottom edge
        }
    }
    
    // MARK: - Subviews or Computed Vars
    
    /// The swipeable card for each structure.
    private func cardView(for structure: Structure) -> some View {
        ZStack(alignment: .bottom) {
            Image(structure.images[0])
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width - 60,
                       height: UIScreen.main.bounds.height * 0.50) // Reduced height
                .clipped()
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color, lineWidth: 4)
                )
            
            Text(structure.title)
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .frame(width: UIScreen.main.bounds.width - 60)
                .background(Color.black.opacity(0.7))
                .cornerRadius(20)
                .foregroundColor(.white)
        }
        .shadow(radius: 10)
    }
    
    /// A button to save progress and dismiss the swiping view.
    private var exitButton: some View {
        Button(action: {
            saveProgress()
            appState.activeFullScreenView = nil
        }) {
            HStack(spacing: 8) {
                Text("Exit")
                    .font(.system(size: 18, weight: .bold))
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.6))
                    .background(Material.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.5),
                                .white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Swipe Logic
    
    /// Handles the swipe logic based on the horizontal width of the swipe.
    private func swipeCard(width: CGFloat) {
        if abs(width) > swipeThreshold {
            if width > 0 {
                likeStructure()
            } else {
                dislikeStructure()
            }
            
            // Check if this is the last structure before moving
            if currentIndex == dataStore.structures.count - 1 {
                withAnimation(.easeOut(duration: 0.3)) {
                    currentIndex = dataStore.structures.count // Move to completion view
                    saveProgress()
                }
            } else {
                moveToNextCard()
            }
        }
        offset = .zero
    }
    
    /// Moves to the next card or marks the process finished if at the end.
    private func moveToNextCard() {
        withAnimation {
            currentIndex += 1
            saveProgress()
        }
    }
    
    
    /// Likes the current structure and updates the liked count.
    private func likeStructure() {
        dataStore.toggleLike(for: dataStore.structures[currentIndex].id)
        updateLikedCount()
    }
    
    /// Dislikes the current structure if it was liked.
    private func dislikeStructure() {
        if dataStore.structures[currentIndex].isLiked {
            dataStore.toggleLike(for: dataStore.structures[currentIndex].id)
            updateLikedCount()
        }
    }
    
    /// Updates the count of liked structures.
    private func updateLikedCount() {
        likedCount = dataStore.structures.filter { $0.isLiked }.count
    }
    
    /// Persists the current rating progress to UserDefaults.
    private func saveProgress() {
        appState.tinderModeStructureNum = currentIndex
    }
    
    private var progressText: String {
        "\(currentIndex + 1)/\(dataStore.structures.count)"
    }
}

// MARK: - CompletionView (Subview)

/// The summary screen shown after all structures are rated.
private struct CompletionView: View {
    @EnvironmentObject var appState: AppState
    @Binding var likedCount: Int
    
    let onRestart: () -> Void
    let onExit: () -> Void
    
    private var percentage: Int {
        Int((Double(likedCount) / Double(DataStore.shared.structures.count)) * 100)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            
            Text("✅")
                .font(.system(size: 80))
                .padding(.bottom, 0)
            
            Text("That was a lot!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
            
            Text("You liked **\(likedCount)** structures\nThat's **\(percentage)%**, good job!")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
                .lineSpacing(8)
            
            VStack(spacing: 10) {
                Button(action: onRestart) {
                    HStack{
                        Text("Start Over")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        
                        
                    }
                    .frame(width: 140, height: 50)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.7))
                            .background(Material.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.5),
                                        .white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                        )
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                
                Button(action: onExit) {
                    HStack(spacing: 5) {
                        Text("Exit")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    
                    }
                        .frame(width: 80, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.6))
                                .background(Material.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.5),
                                            .white.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.top, 20)
        }
        .padding()
    }
}

// MARK: - Additional Subviews and Utilities

/// A heart image that pulses to indicate completion.
struct PulsingHeart: View {
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.red)
            .scaleEffect(scale)
            .animation(
                Animation.easeInOut(duration: 1)
                    .repeatForever(autoreverses: true),
                value: scale
            )
            .onAppear {
                scale = 1.2
            }
    }
}

/**
 * RoundedCorner
 *
 * A shape that allows for specific corners to be rounded. 
 * Typically used in the card overlays.
 */
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

/**
 * SwipeDirection
 *
 * Enum representing the direction of a swipe gesture.
 */
enum SwipeDirection {
    case left, right, top, bottom
}

// MARK: - CardSwiperView (Unchanged)

public struct CardSwiperView<Content: View>: View {
    @Binding var cards: [Content]
    
    var onCardSwiped: ((SwipeDirection, Int) -> Void)?
    var onCardDragged: ((SwipeDirection, Int, CGSize) -> Void)?
    var initialOffsetY: CGFloat = 5
    var initialRotationAngle: Double = 0.5
    
    init(
        cards: Binding<[Content]>,
        onCardSwiped: ((SwipeDirection, Int) -> Void)? = nil,
        onCardDragged: ((SwipeDirection, Int, CGSize) -> Void)? = nil,
        initialOffsetY: CGFloat = 5,
        initialRotationAngle: Double = 0.5
    ) {
        self._cards = cards
        self.onCardSwiped = onCardSwiped
        self.onCardDragged = onCardDragged
        self.initialOffsetY = initialOffsetY
        self.initialRotationAngle = initialRotationAngle
    }
    
    public var body: some View {
        ZStack {
            ForEach(cards.indices, id: \.self) { index in
                CardView(
                    index: index,
                    onCardSwiped: { swipeDirection in
                        onCardSwiped?(swipeDirection, index)
                    },
                    onCardDragged: { direction, i, offset in
                        onCardDragged?(direction, i, offset)
                    },
                    content: {
                        cards[index]
                    },
                    initialOffsetY: initialOffsetY,
                    initialRotationAngle: initialRotationAngle,
                    zIndex: Double(cards.count - index)
                )
                .id(UUID())
            }
        }
    }
    
    // MARK: - CardView (Internal)
    private struct CardView<CardContent: View>: View {
        var index: Int
        var onCardSwiped: ((SwipeDirection) -> Void)?
        var onCardDragged: ((SwipeDirection, Int, CGSize) -> Void)?
        var content: () -> CardContent
        var initialOffsetY: CGFloat
        var initialRotationAngle: Double
        var zIndex: Double
        
        @State private var offset = CGSize.zero
        @State private var overlayColor: Color = .clear
        @State private var isRemoved = false
        @State private var activeCardIndex: Int?
        
        var body: some View {
            ZStack {
                content()
                    .frame(width: 320, height: 420)
                    .offset(x: offset.width, y: offset.height)
                    .rotationEffect(.degrees(Double(offset.width / 40)))
                    .zIndex(zIndex)
                
                Rectangle()
                    .foregroundColor(overlayColor)
                    .opacity(isRemoved ? 0 : (activeCardIndex == index ? 1 : 0))
                    .frame(width: 320, height: 420)
                    .cornerRadius(10)
                    .blendMode(.overlay)
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                        activeCardIndex = index
                        withAnimation {
                            handleCardDragging(offset)
                        }
                    }
                    .onEnded { _ in
                        withAnimation {
                            handleSwipe(offsetWidth: offset.width, offsetHeight: offset.height)
                        }
                    }
            )
            .opacity(isRemoved ? 0 : 1)
        }
        
        private func handleCardDragging(_ offset: CGSize) {
            var swipeDirection: SwipeDirection = .left
            switch (offset.width, offset.height) {
            case (-500...(-150), _):
                swipeDirection = .left
            case (150...500, _):
                swipeDirection = .right
            case (_, -500...(-150)):
                swipeDirection = .top
            case (_, 150...500):
                swipeDirection = .bottom
            default:
                break
            }
            onCardDragged?(swipeDirection, index, offset)
        }
        
        private func handleSwipe(offsetWidth: CGFloat, offsetHeight: CGFloat) {
            var swipeDirection: SwipeDirection = .left
            switch (offsetWidth, offsetHeight) {
            case (-500...(-150), _):
                swipeDirection = .left
                offset = CGSize(width: -500, height: 0)
                isRemoved = true
                onCardSwiped?(swipeDirection)
            case (150...500, _):
                swipeDirection = .right
                offset = CGSize(width: 500, height: 0)
                isRemoved = true
                onCardSwiped?(swipeDirection)
            case (_, -500...(-150)):
                swipeDirection = .top
                offset = CGSize(width: 0, height: -500)
                isRemoved = true
                onCardSwiped?(swipeDirection)
            case (_, 150...500):
                swipeDirection = .bottom
                offset = CGSize(width: 0, height: 500)
                isRemoved = true
                onCardSwiped?(swipeDirection)
            default:
                offset = .zero
                overlayColor = .clear
            }
        }
    }
}

// MARK: - Preview

struct StructureSwipingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RatingsView()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = false
                    return state
                }())
                .environmentObject(DataStore.shared)
                .previewDisplayName("Light Mode")
            
            RatingsView()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = true
                    return state
                }())
                .environmentObject(DataStore.shared)
                .previewDisplayName("Dark Mode")
        }
    }
}

// Add new StartingView
private struct StartingView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("🏛️💫")
                .font(.system(size: 80))
                .padding(.bottom, 0)
            
            Text("Ready to Rate?")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(appState.isDarkMode ? .white : .black)

            HStack (spacing: 0) {
                Text("Swipe right ")
                    .font(.system(size: 16, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
                    .lineSpacing(8)
                Text("to like a structure")
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
                    .lineSpacing(8)
            }
            .padding(.bottom, -15)

            HStack (spacing: 0) {
                Text("Swipe left ")
                    .font(.system(size: 16, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
                    .lineSpacing(8)
                Text("if it's not for you")
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
                    .lineSpacing(8)
            }

            
            Button(action: {
                appState.tinderModeStructureNum = 0
            }) {
                Text("Let's Start!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.green.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.5),
                                                .white.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5
                                    )
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 10)
            
            Spacer()
            
            Button(action: {
                appState.activeFullScreenView = nil
            }) {
                Text("Maybe Later")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 140, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.black.opacity(0.6))
                            .background(Material.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.5),
                                        .white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 30)
        }
        .padding()
    }
}
