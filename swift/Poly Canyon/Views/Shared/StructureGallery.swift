import SwiftUI
import Zoomable

/// Shared by the regular and historical catalogs; page identity resets with the structure.
struct StructureGallery: View {
    let structure: Structure
    let allowsFavorites: Bool
    let onClose: () -> Void
    @EnvironmentObject private var dataStore: DataStore
    @State private var currentIndex = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                TabView(selection: $currentIndex) {
                    ForEach(structure.images.indices, id: \.self) { index in
                        ZStack {
                            Image(structure.images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .blur(radius: 8)
                                .clipped()
                                .accessibilityHidden(true)
                            Image(structure.images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .zoomable()
                                .accessibilityLabel("\(structure.title), photo \(index + 1) of \(structure.images.count)")
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                if structure.images.count > 1 {
                    HStack {
                        galleryButton("Previous photo", icon: "chevron.left") { currentIndex -= 1 }
                            .disabled(currentIndex == 0)
                        Spacer()
                        galleryButton("Next photo", icon: "chevron.right") { currentIndex += 1 }
                            .disabled(currentIndex >= structure.images.count - 1)
                    }
                    .padding(.horizontal, 12)
                }

                VStack {
                    Spacer()
                    HStack {
                        galleryButton("Back to information", icon: "arrow.down.right.and.arrow.up.left", action: onClose)
                        Spacer()
                        Text("\(structure.images.isEmpty ? 0 : currentIndex + 1) / \(structure.images.count)")
                            .font(.callout.monospacedDigit())
                            .padding(8)
                            .background(.ultraThinMaterial, in: Capsule())
                            .accessibilityLabel("Photo \(currentIndex + 1) of \(structure.images.count)")
                        Spacer()
                        if allowsFavorites {
                            galleryButton(dataStore.isLiked(for: structure.number) ? "Remove favorite" : "Add favorite",
                                          icon: dataStore.isLiked(for: structure.number) ? "heart.fill" : "heart") {
                                dataStore.toggleLike(for: structure.number)
                            }
                        } else {
                            Color.clear.frame(width: 44, height: 44)
                        }
                    }
                    .padding(20)
                }
            }
            .onChange(of: structure.number) { _ in currentIndex = 0 }
        }
    }

    private func galleryButton(_ label: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
