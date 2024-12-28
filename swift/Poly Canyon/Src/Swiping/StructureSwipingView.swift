// MARK: - StructureSwipingView.swift

/*
    StructureSwipingView.swift

    This file defines the StructureSwipingView, which allows users to swipe through structures to like or dislike them.

    Key Components:
    - Swipeable cards with like/dislike functionality
    - Progress tracking with indicator
    - Completion view with summary
    - Dark mode support
    - Exit button to dismiss the view

    The view is designed to be presented as a full-screen overlay and adapts its layout based on the device's screen size.
*/

import SwiftUI

// MARK: - StructureSwipingView

struct StructureSwipingView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State Properties
    @State private var currentIndex: Int
    @State private var offset: CGSize = .zero
    @State private var color: Color = .black
    @State private var likedCount = 0
    @State private var hasFinishedRating = false
    
    // MARK: - Constants
    private let swipeThreshold: CGFloat = 50.0
    
    // MARK: - Initializer
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
                if !hasFinishedRating {
                    ratingContent
                } else {
                    completionView
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            updateLikedCount()
        }
    }
    
    // MARK: - Sections
    
    /**
     * backgroundColor
     *
     * Determines the background color based on dark mode.
     */
    private var backgroundColor: Color {
        appState.isDarkMode ? .black : .white
    }
    
    /**
     * ratingContent
     *
     * Displays the swipeable cards and controls for liking or disliking structures.
     */
    private var ratingContent: some View {
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
            
            exitButton
        }
    }
    
    /**
     * completionView
     *
     * Displays a summary of liked structures upon completion of rating.
     */
    private var completionView: some View {
        VStack(spacing: 0) {
            PulsingHeart()
                .frame(width: 100, height: 100)
                .padding(.bottom, 15)
            
            Text("Rating Complete!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .padding(.bottom, 10)
            Text("\(likedCount)/\(dataStore.structures.count) structures liked")
                .font(.headline)
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .padding(.bottom, 15)
            
            HStack(spacing: 15) {
                // Restart Rating Button
                Button(action: restartRating) {
                    Label("Restart", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                // Exit Button
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
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
    
    /**
     * exitButton
     *
     * A button to save progress and dismiss the swiping view.
     */
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
    
    /**
     * cardView
     *
     * Renders each individual swipeable card.
     */
    private func cardView(for structure: Structure) -> some View {
        ZStack(alignment: .bottom) {
            Image(structure.mainPhoto)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height * 0.6)
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
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
        }
        .shadow(radius: 10)
    }
    
    /**
     * completionView
     *
     * Displays a summary of liked structures upon completion of rating.
     */
    private var completionView: some View {
        VStack(spacing: 0) {
            PulsingHeart()
                .frame(width: 100, height: 100)
                .padding(.bottom, 15)
            
            Text("Rating Complete!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .padding(.bottom, 10)
            Text("\(likedCount)/\(dataStore.structures.count) structures liked")
                .font(.headline)
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .padding(.bottom, 15)
            
            HStack(spacing: 15) {
                // Restart Rating Button
                Button(action: restartRating) {
                    Label("Restart", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                // Exit Button
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
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
    
    // MARK: - Helper Functions
    
    /**
     * swipeCard
     *
     * Handles the swipe action based on the swipe width.
     */
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
    
    /**
     * moveToNextCard
     *
     * Advances to the next card or marks rating as finished if all cards are swiped.
     */
    private func moveToNextCard() {
        if currentIndex < dataStore.structures.count - 1 {
            currentIndex += 1
            saveProgress()
        } else {
            hasFinishedRating = true
            UserDefaults.standard.set(true, forKey: "ratingCompleted")
        }
    }
    
    /**
     * likeStructure
     *
     * Toggles the like status of the current structure and updates the liked count.
     */
    private func likeStructure() {
        dataStore.toggleLike(for: dataStore.structures[currentIndex].id)
        updateLikedCount()
    }
    
    /**
     * dislikeStructure
     *
     * Removes the like status if the structure is currently liked.
     */
    private func dislikeStructure() {
        if dataStore.structures[currentIndex].isLiked {
            dataStore.toggleLike(for: dataStore.structures[currentIndex].id)
            updateLikedCount()
        }
    }
    
    /**
     * updateLikedCount
     *
     * Updates the count of liked structures.
     */
    private func updateLikedCount() {
        likedCount = dataStore.structures.filter { $0.isLiked }.count
    }
    
    /**
     * restartRating
     *
     * Resets the rating process to allow the user to start over.
     */
    private func restartRating() {
        currentIndex = 0
        hasFinishedRating = false
        UserDefaults.standard.set(false, forKey: "ratingCompleted")
        saveProgress()
        updateLikedCount()
    }
    
    /**
     * saveProgress
     *
     * Saves the current progress of the rating process.
     */
    private func saveProgress() {
        UserDefaults.standard.set(currentIndex, forKey: "ratingProgress")
    }
}

// MARK: - Supporting Views

/**
 * PulsingHeart
 *
 * A heart image that pulses to indicate completion.
 */
struct PulsingHeart: View {
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.red)
            .scaleEffect(scale)
            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: scale)
            .onAppear {
                self.scale = 1.2
            }
    }
}

/**
 * RoundedCorner
 *
 * A shape that allows for specific corners to be rounded.
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
 * An enum to represent the direction of a swipe gesture.
 */
enum SwipeDirection {
    case left, right, top, bottom
}

/**
 * CardSwiperView
 *
 * A reusable view that manages the swiping of cards.
 */
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
                    onCardDragged: { direction, index, offset in
                        onCardDragged?(direction, index, offset)
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
    
    // MARK: - CardView

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
                    .onEnded { gesture in
                        withAnimation {
                            handleSwipe(offsetWidth: offset.width, offsetHeight: offset.height)
                        }
                    }
            )
            .opacity(isRemoved ? 0 : 1)
        }
        
        /**
         * handleCardDragging
         *
         * Updates the overlay color based on the swipe direction during dragging.
         */
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
        
        /**
         * handleSwipe
         *
         * Determines whether to swipe the card away or reset its position based on the swipe threshold.
         */
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

// MARK: - Supporting Views

/**
 * PulsingHeart
 *
 * A heart image that pulses to indicate completion.
 */
struct PulsingHeart: View {
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.red)
            .scaleEffect(scale)
            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: scale)
            .onAppear {
                self.scale = 1.2
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
