import SwiftUI

struct SimpleStructureRatingView: View {
    @ObservedObject var structureData: StructureData
    @Binding var isDarkMode: Bool
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("ratingProgress") private var ratingProgress: Int = 0
    @State private var currentIndex: Int
    @State private var offset: CGSize = .zero
    @State private var color: Color = .black
    @State private var likedCount = 0

    private let swipeThreshold: CGFloat = 50.0

    init(structureData: StructureData, isDarkMode: Binding<Bool>) {
        self.structureData = structureData
        self._isDarkMode = isDarkMode
        self._currentIndex = State(initialValue: UserDefaults.standard.integer(forKey: "ratingProgress"))
    }

    var body: some View {
        ZStack {
            backgroundColor

            VStack {
                Text("Rate Structures")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .foregroundColor(isDarkMode ? .white : .black)

                if currentIndex < structureData.structures.count {
                    Text("\(currentIndex + 1)/\(structureData.structures.count)")
                        .font(.headline)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(.bottom, 5)

                    ZStack {
                        cardView(for: structureData.structures[currentIndex])
                            .offset(offset)
                            .rotationEffect(.degrees(Double(offset.width / 10)))
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        offset = gesture.translation
                                        withAnimation {
                                            color = offset.width > 0 ? .green : .red
                                        }
                                    }
                                    .onEnded { _ in
                                        withAnimation {
                                            swipeCard(width: offset.width)
                                            color = .black
                                        }
                                    }
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)

                    HStack(spacing: 60) {
                        Button(action: { swipeCard(width: -500) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 50))
                        }

                        Button(action: { swipeCard(width: 500) }) {
                            Image(systemName: "heart.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 50))
                        }
                    }
                    .padding(.bottom, 5)

                } else {
                    completionView
                }

                Spacer()

                Button(action: {
                    saveProgress()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Exit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

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

    private func moveToNextCard() {
        currentIndex += 1
        saveProgress()
        if currentIndex >= structureData.structures.count {
            resetProgress()
        }
    }

    private func likeStructure() {
        structureData.toggleLike(for: structureData.structures[currentIndex].id)
        likedCount += 1
    }

    private func dislikeStructure() {
        if structureData.structures[currentIndex].isLiked {
            structureData.toggleLike(for: structureData.structures[currentIndex].id)
            likedCount -= 1
        }
    }

    private func saveProgress() {
        UserDefaults.standard.set(currentIndex, forKey: "ratingProgress")
    }

    private func resetProgress() {
        currentIndex = 0
        UserDefaults.standard.set(0, forKey: "ratingProgress")
    }

    private var completionView: some View {
        VStack(spacing: 20) {
            Text("Rating Complete!")
                .font(.title)
                .fontWeight(.bold)

            Text("\(likedCount)/\(structureData.structures.count) structures liked")
                .font(.headline)

            Button("Start Over") {
                resetProgress()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
        .foregroundColor(isDarkMode ? .white : .black)
    }

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
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.7))
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
        }
        .shadow(radius: 10)
    }

    private var backgroundColor: Color {
        isDarkMode ? .black : .white
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct StructureCard: View {
    let structure: Structure
    @Binding var isDarkMode: Bool

    var body: some View {
        StructPopUp(structure: structure, isDarkMode: $isDarkMode, onDismiss: {})
    }
}

enum SwipeDirection {
    case left, right, top, bottom
}

public struct CardSwiperView<Content: View>: View {
    @Binding var cards: [Content]
    
    var onCardSwiped: ((SwipeDirection, Int) -> Void)?
    var onCardDragged: ((SwipeDirection, Int, CGSize) -> Void)? // New callback
    var initialOffsetY: CGFloat = 5
    var initialRotationAngle: Double = 0.5
    
    init(
        cards: Binding<[Content]>,
        onCardSwiped: ((SwipeDirection, Int) -> Void)? = nil,
        onCardDragged: ((SwipeDirection, Int, CGSize) -> Void)? = nil, // Initialize new callback
        initialOffsetY: CGFloat = 5,
        initialRotationAngle: Double = 0.5
    ) {
        self._cards = cards
        self.onCardSwiped = onCardSwiped
        self.onCardDragged = onCardDragged // Set the new callback
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
                    onCardDragged: { direction, index, offset in // Pass the drag details to the callback
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
    
    private struct CardView<Content: View>: View {
        var index: Int
        var onCardSwiped: ((SwipeDirection) -> Void)?
        var onCardDragged: ((SwipeDirection, Int, CGSize) -> Void)? // New callback
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
                    .offset(x: offset.width * 1, y: offset.height * 0.8)
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
                            handleCardDragging(offset) // Handle card dragging
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
        
        func handleCardDragging(_ offset: CGSize) {
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
            
            onCardDragged?(swipeDirection, index, offset) // Trigger the new callback
        }
        
        func handleSwipe(offsetWidth: CGFloat, offsetHeight: CGFloat) {
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
                overlayColor = .clear // If not completely removed, change overlay color to clear
            }
        }
    }
}
