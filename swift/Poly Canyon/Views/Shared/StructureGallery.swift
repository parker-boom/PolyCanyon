import SwiftUI
import Zoomable

/// Every photograph remains available offline, at its original aspect ratio.
struct StructureGallery: View {
    let structure: Structure
    let onClose: () -> Void
    @State private var currentIndex: Int

    init(structure: Structure, initialIndex: Int = 0, onClose: @escaping () -> Void) {
        self.structure = structure
        self.onClose = onClose
        _currentIndex = State(initialValue: min(max(initialIndex, 0), max(structure.images.count - 1, 0)))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                if structure.images.isEmpty {
                    Text("No photographs available").foregroundStyle(.white)
                } else {
                    TabView(selection: $currentIndex) {
                        ForEach(structure.images.indices, id: \.self) { index in
                            Image(structure.images[index])
                                .resizable().scaledToFit()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .zoomable()
                                .tag(index)
                                .accessibilityLabel("\(structure.title), photo \(index + 1) of \(structure.images.count)")
                                .accessibilityHint("Pinch or double-tap to zoom")
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
        }
        .safeAreaInset(edge: .top) {
            HStack(alignment: .center) {
                Text(structure.title).font(.headline).foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                galleryButton("Close photographs", icon: "xmark", action: onClose)
                    .keyboardShortcut(.cancelAction)
            }.padding(.horizontal, 20).padding(.vertical, 12).background(.black)
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                galleryButton("Previous photo", icon: "chevron.left") { currentIndex = max(0, currentIndex - 1) }
                    .disabled(currentIndex == 0)
                Spacer()
                Text("\(structure.images.isEmpty ? 0 : currentIndex + 1) / \(structure.images.count)")
                    .font(.callout.monospacedDigit()).foregroundStyle(.white)
                    .accessibilityLabel("Photo \(structure.images.isEmpty ? 0 : currentIndex + 1) of \(structure.images.count)")
                Spacer()
                galleryButton("Next photo", icon: "chevron.right") { currentIndex = min(structure.images.count - 1, currentIndex + 1) }
                    .disabled(currentIndex >= structure.images.count - 1)
            }.padding(.horizontal, 20).padding(.vertical, 12).background(.black)
        }
        .background(.black)
        .tint(.white)
        .preferredColorScheme(.dark)
        .onChange(of: structure.number) { _ in currentIndex = 0 }
    }

    @ViewBuilder
    private func galleryButton(_ label: String, icon: String, action: @escaping () -> Void) -> some View {
        if #available(iOS 26, *) {
            Button(action: action) {
                Image(systemName: icon).font(.body.weight(.semibold)).frame(width: 44, height: 44)
            }
            .buttonStyle(.glass)
            .accessibilityLabel(label)
        } else {
            Button(action: action) {
                Image(systemName: icon).font(.body.weight(.semibold)).frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(label)
        }
    }
}
