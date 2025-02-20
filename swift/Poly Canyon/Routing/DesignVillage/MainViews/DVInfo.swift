import SwiftUI

struct DVInfo: View {
    @State private var isHistoryExpanded = true
    @State private var isWhatIsExpanded = true
    @State private var isGalleryExpanded = true
    @State private var currentImageIndex = 0
    @State private var showFullHistory = false
    
    private let images = ["DV1", "DV2", "DV3", "DV4", "DV5", "DV6"]
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(spacing: 24) {
                    whatIsSection
                    imageCarousel
                    historySection
                }
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 40)
            }
        }
        .background(Color(white: 0.98))
    }
    
    private var header: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .ignoresSafeArea(edges: .top)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
            
            HStack {
                Text("Info")
                    .font(.system(size: 32, weight: .bold))

                Spacer()
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.black, Color.gray],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
        .frame(height: 50)
        .padding(.bottom, 5)
    }
    
    private var whatIsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("What Is Design Village?")
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isWhatIsExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .rotationEffect(.degrees(isWhatIsExpanded ? -180 : 0))
                }
            }
            
            if isWhatIsExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Design Village is Cal Poly's signature hands-on design-build competition, where first-year architecture students and visiting college teams construct temporary shelters right here in Poly Canyon. Teams spend months designing their structures, carefully selecting materials, and planning the build. During the event, they'll construct their shelters on-site, live in them overnight, and later dismantle them—experiencing the full lifecycle of a construction project. Cal Poly students receive studio grades for their work, while visiting teams compete for awards based on innovation, sustainability, and craftsmanship.")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.8))
                        .lineSpacing(4)
                    
                    Text("Theme: Nexus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black.opacity(0.9))
                        .padding(.top, 8)
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    private var imageCarousel: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Through The Years")
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isGalleryExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .rotationEffect(.degrees(isGalleryExpanded ? -180 : 0))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            
            if isGalleryExpanded {
                TabView(selection: $currentImageIndex) {
                    ForEach(0..<images.count, id: \.self) { index in
                        Image(images[index])
                            .resizable()
                            .scaledToFill()
                            .tag(index)
                    }
                }
                .frame(height: 240)
                .clipShape(
                    BottomRoundedRectangle(cornerRadius: 16)
                )
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .onReceive(timer) { _ in
                    withAnimation {
                        currentImageIndex = (currentImageIndex + 1) % images.count
                    }
                }
                .transition(.opacity)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("The History")
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isHistoryExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .rotationEffect(.degrees(isHistoryExpanded ? -180 : 0))
                }
            }
            
            if isHistoryExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Design Village emerged from the early use of Poly Canyon as an experimental site for campus projects. Initially part of the broader Poly Royal open house activities in the early 1970s, students saw the canyon as the perfect place to test out temporary, buildable projects. By 1974, the first official Design Village took shape. Over time, the event evolved—with themed challenges and formal judging—into a key part of the Cal Poly experience, emphasizing practical, real-world construction skills.")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.8))
                        .lineSpacing(4)
                    
                    if showFullHistory {
                        Text("By 1974, a group of students formally pitched and executed the first Design Village, transforming the canyon into a live construction site. Early projects were simple and experimental, designed to be built quickly and then dismantled, embodying the full lifecycle of a construction project. As the event matured, formal judging categories and themed challenges (from straightforward design contests to more complex, conceptual themes) were introduced, reflecting shifts in design practices and campus culture.")
                            .font(.system(size: 16))
                            .foregroundColor(.black.opacity(0.8))
                            .lineSpacing(4)
                            .padding(.top, 8)
                        
                        Text("Despite challenges along the way—such as periods of low participation and issues with maintenance—the commitment to hands-on learning never waned. Revitalization efforts in the 1990s and again in the 2000s have reinforced the importance of Design Village as a practical training ground. Today, in its 50th anniversary, Design Village stands as a living tradition that not only preserves the spirit of experimental learning in Poly Canyon but also continues to prepare future architects for the realities of construction, teamwork, and creative problem-solving.")
                            .font(.system(size: 16))
                            .foregroundColor(.black.opacity(0.8))
                            .lineSpacing(4)
                            .padding(.top, 8)
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showFullHistory.toggle()
                        }
                    } label: {
                        Text(showFullHistory ? "Show Less" : "Learn More")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

struct DVInfo_Previews: PreviewProvider {
    static var previews: some View {
        DVInfo()
    }
}
