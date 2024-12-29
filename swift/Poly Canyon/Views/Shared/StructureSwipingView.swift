/*
 StructureSwipingView implements a Tinder-style card swiping interface for rating structures. It manages 
 the rating flow with swipe gestures and like/dislike buttons, tracks progress, and shows a completion 
 view when finished. The view persists rating progress and adapts to the app theme. It provides haptic 
 feedback and smooth animations for card transitions.
*/

import SwiftUI

// MARK: - StructureSwipingView (Top-Level Container)

struct StructureSwipingView: View {
    // MARK: - Environment
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    // MARK: - Presentation
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State
    @State private var currentIndex: Int
    @State private var offset: CGSize = .zero
    @State private var color: Color = .black
    @State private var likedCount = 0
    @State private var hasFinishedRating = false
    
    // MARK: - Constants
    private let swipeThreshold: CGFloat = 50.0
    
    // MARK: - Init
    init() {
        let savedIndex = UserDefaults.standard.integer(forKey: "ratingProgress")
        let isCompleted = UserDefaults.standard.bool(forKey: "ratingCompleted")
        self._currentIndex = State(initialValue: savedIndex)
        self._hasFinishedRating = State(initialValue: isCompleted)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundColor
            
            VStack {

                // Show structures to rate
                if !hasFinishedRating {
                    RatingContentView(
                        currentIndex: $currentIndex,
                        offset: $offset,
                        color: $color,
                        likedCount: $likedCount,
                        swipeThreshold: swipeThreshold,
                        hasFinishedRating: $hasFinishedRating
                    )
                
                // Show completed view
                } else {
                    CompletionView(
                        likedCount: $likedCount,
                        onRestart: restartRating,
                        onExit: { presentationMode.wrappedValue.dismiss() }
                    )
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
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
    
    /// Resets the rating flow so the user can start over.
    private func restartRating() {
        currentIndex = 0
        hasFinishedRating = false
        UserDefaults.standard.set(false, forKey: "ratingCompleted")
        saveProgress()
        updateLikedCount()
    }
    
    /// Saves current progress in UserDefaults.
    private func saveProgress() {
        UserDefaults.standard.set(currentIndex, forKey: "ratingProgress")
    }
}

// MARK: - RatingContentView (Subview)

/// The main rating UI: a title, progress text, swipeable cards, plus like/dislike buttons and an exit button.
private struct RatingContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var currentIndex: Int
    @Binding var offset: CGSize
    @Binding var color: Color
    @Binding var likedCount: Int
    
    let swipeThreshold: CGFloat
    @Binding var hasFinishedRating: Bool
    
    var body: some View {
        VStack {
            Text("Rate Structures")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .padding(.top, 20)
            
            Text("\(currentIndex + 1)/\(dataStore.structures.count)")
                .font(.headline)
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .padding(.bottom, 5)
            
            ZStack {
                ForEach(dataStore.structures.indices, id: \.self) { index in
                    if index >= currentIndex && index <= currentIndex + 2 {
                        cardView(for: dataStore.structures[index])
                            .offset(index == currentIndex ? offset : .zero)
                            .rotationEffect(.degrees(Double(index == currentIndex ? offset.width / 10 : 0)))
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
                            .zIndex(Double(dataStore.structures.count - index))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            HStack(spacing: 60) {
                // Dislike Button
                Button(action: { swipeCard(width: -500) }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 50))
                }
                
                // Like Button
                Button(action: { swipeCard(width: 500) }) {
                    Image(systemName: "heart.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 50))
                }
            }
            .padding(.bottom, 20)
            
            // Exit button at bottom
            exitButton
        }
    }
    
    // MARK: - Subviews or Computed Vars
    
    /// The swipeable card for each structure.
    private func cardView(for structure: Structure) -> some View {
        ZStack(alignment: .bottom) {
            Image(structure.mainPhoto)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width - 40,
                       height: UIScreen.main.bounds.height * 0.6)
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
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
        }
        .shadow(radius: 10)
    }
    
    /// A button to save progress and dismiss the swiping view.
    private var exitButton: some View {
        Button(action: {
            saveProgress()
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Exit")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.red)
                .underline()
                .padding(.vertical, 15)
        }
        .padding(.bottom, 30)
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
            moveToNextCard()
        }
        offset = .zero
    }
    
    /// Moves to the next card or marks the process finished if at the end.
    private func moveToNextCard() {
        if currentIndex < dataStore.structures.count - 1 {
            currentIndex += 1
            saveProgress()
        } else {
            hasFinishedRating = true
            UserDefaults.standard.set(true, forKey: "ratingCompleted")
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
        UserDefaults.standard.set(currentIndex, forKey: "ratingProgress")
    }
}

// MARK: - CompletionView (Subview)

/// The summary screen shown after all structures are rated.
private struct CompletionView: View {
    @EnvironmentObject var appState: AppState
    @Binding var likedCount: Int
    
    let onRestart: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            PulsingHeart()
                .frame(width: 100, height: 100)
                .padding(.bottom, 15)
            
            Text("Rating Complete!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .padding(.bottom, 10)
            
            Text("\(likedCount)/\(DataStore.shared.structures.count) structures liked")
                .font(.headline)
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .padding(.bottom, 15)
            
            HStack(spacing: 15) {
                // Restart
                Button(action: onRestart) {
                    Label("Restart", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                // Exit
                Button(action: onExit) {
                    Label("Exit", systemImage: "xmark.circle")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
        }
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
    private struct CardView<Content: View>: View {
        var index: Int
        var onCardSwiped: ((SwipeDirection) -> Void)?
        var onCardDragged: ((SwipeDirection, Int, CGSize) -> Void)?
        var content: () -> Content
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
            StructureSwipingView()
                .environmentObject(AppState())
                .environmentObject(DataStore.shared)
                .previewDisplayName("Light Mode")
            
            StructureSwipingView()
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
