import SwiftUI
import UIKit

/// Every photograph remains available offline, at its original aspect ratio.
struct StructureGallery: View {
    let structure: Structure
    let onClose: () -> Void
    let transitionNamespace: Namespace.ID?
    let visibleSourceIndices: Set<Int>
    @State private var currentIndex: Int

    init(structure: Structure, initialIndex: Int = 0, transitionNamespace: Namespace.ID? = nil, visibleSourceIndices: Set<Int> = [], onClose: @escaping () -> Void) {
        self.structure = structure
        self.onClose = onClose
        self.transitionNamespace = transitionNamespace
        self.visibleSourceIndices = visibleSourceIndices
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
                            ZoomableStoryPhoto(asset: structure.images[index], size: geometry.size)
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
        // This is a dark surface inside a light story presentation. A preferred
        // scheme propagates to the enclosing presentation and can survive its
        // nested zoom dismissal; keep the override local to the gallery instead.
        .environment(\.colorScheme, .dark)
        .statusBarHidden()
        .onChange(of: structure.number) { _ in currentIndex = 0 }
        .modifier(StoryPhotoDestination(id: StoryPhotoID(structure: structure.number, index: currentIndex),
                                        namespace: transitionNamespace,
                                        hasVisibleSource: visibleSourceIndices.contains(currentIndex)))
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

/// Index distinguishes repeated assets while structure scopes each story's photographs.
struct StoryPhotoID: Hashable {
    let structure: Int
    let index: Int
}

private struct StoryPhotoDestination: ViewModifier {
    let id: StoryPhotoID
    let namespace: Namespace.ID?
    let hasVisibleSource: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if #available(iOS 18, *) {
            if let namespace, hasVisibleSource, !reduceMotion {
                content.navigationTransition(.zoom(sourceID: id, in: namespace))
            } else {
                content.navigationTransition(.automatic)
            }
        } else { content }
    }
}

private struct ZoomableStoryPhoto: View {
    let asset: String
    let size: CGSize
    @State private var camera = UUID()
    var body: some View {
        let original = UIImage(named: asset)?.size ?? size
        let scale = min(size.width / max(1, original.width), size.height / max(1, original.height))
        let fitted = CGSize(width: original.width * scale, height: original.height * scale)
        CanyonMapViewport(request: camera, focus: nil, canvasSize: fitted, select: { _ in }) {
            Image(asset).resizable().scaledToFit().frame(width: fitted.width, height: fitted.height)
        }.background(.black).clipped()

    }
}
