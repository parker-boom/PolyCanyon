import SwiftUI


struct StructPopUp: View {
    let structure: Structure?
    @Binding var isDarkMode: Bool
    var onDismiss: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showInfo: Bool = false
    @State private var selectedTab: Int = 0
    @State private var isInfoPanelOpen: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(isDarkMode ? .black : .white).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 15) {
                    ZStack(alignment: .topLeading) {
                        // Image
                        Image(structure?.mainPhoto ?? "")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width - 30, height: geometry.size.height * 0.7)
                            .clipped()
                            .cornerRadius(20)
                            
                        
                        // Close button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2, x: 0, y: 0)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        
                        // Structure number and title
                        VStack {
                            if isInfoPanelOpen {
                                VStack(alignment: .leading) {
                                    Text("\(structure?.number ?? 0)")
                                        .font(.system(size: 40, weight: .bold))
                                    Text(structure?.title ?? "")
                                        .font(.system(size: 30, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2, x: 0, y: 0)
                                .padding(20)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .transition(.move(edge: .top))
                            } else {
                                VStack(alignment: .leading) {
                                    Spacer()
                                    Text("\(structure?.number ?? 0)")
                                        .font(.system(size: 40, weight: .bold))
                                    Text(structure?.title ?? "")
                                        .font(.system(size: 30, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2, x: 0, y: 0)
                                .padding(20)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                .transition(.move(edge: .bottom))
                            }
                        }
                        .animation(.easeInOut, value: isInfoPanelOpen)
                    }
                    .frame(height: geometry.size.height * 0.7)
                    
                    
                    // Information button
                    Button(action: {
                        withAnimation(.spring()) {
                            showInfo.toggle()
                            isInfoPanelOpen.toggle()
                        }
                    }) {
                        HStack {
                            Text(showInfo ? "Close  " : "Information  ")
                                .font(.system(size: 22, weight: .semibold))
                            Image(systemName: showInfo ? "chevron.down" : "chevron.up")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding()
                        .frame(width: geometry.size.width - 30)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 15)
                
                if showInfo {
                    informationPanel(geometry: geometry)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .padding(.top, 20)
        .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    private func informationPanel(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            CustomTabSelector(selectedTab: $selectedTab)
                .padding(.top, 15)
                .padding(.bottom, 10)
            
            TabView(selection: $selectedTab) {
                statisticsView(geometry: geometry)
                    .tag(0)
                
                descriptionView
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .frame(width: geometry.size.width - 30, height: geometry.size.height * 0.4)
        .background(Color(isDarkMode ? .gray : .white).opacity(0.95))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private func statisticsView(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 10) {
                if structure?.year != "iii" {
                    InfoPill(title: "Year", value: structure?.year ?? "")
                }
                if structure?.architecturalStyle != "iii" {
                    InfoPill(title: "Style", value: structure?.architecturalStyle ?? "")
                }
            }
            
            HStack(spacing: 10) {
                if structure?.students != "iii" {
                    InfoPill(title: "Students", value: structure?.students ?? "")
                }
                if structure?.advisors != "iii" {
                    InfoPill(title: "Advisor", value: structure?.advisors ?? "")
                }
            }
            
            if structure?.additionalInfo != "iii" {
                FunFactPill(fact: structure?.additionalInfo ?? "No fun fact available")
            }
            
            Spacer()
        }
        .padding(15)
    }
    
    private var descriptionView: some View {
        ScrollView {
            Text(structure?.description ?? "")
                .font(.system(size: 20))
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.top, 10)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}


struct CustomTabSelector: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            TabButton(icon: "chart.bar.fill", title: "Stats", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabButton(icon: "info.circle.fill", title: "Info", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 16, weight: .semibold))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.blue : Color.clear)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(15)
        }
    }
}

struct InfoPill: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
    }
}

struct FunFactPill: View {
    let fact: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Fun Fact")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            Text(fact)
                .font(.system(size: 16, weight: .medium))
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .opacity(isAnimating ? 0.8 : 0.4)
                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
        )
        .onAppear {
            isAnimating = true
        }
    }
}

struct StructPopUp_Previews: PreviewProvider {
    static var previews: some View {
        StructPopUp(
            structure: Structure(
                number: 1,
                title: "Sample Structure",
                description: "An unfinished structure built between 1983-1989, intended to include innovative features like an automatic watering system and sun-generated heating. It was operational from 2006-2008 and designed by Mark Jenefsky.",
                year: "2023",
                students: "John Doe, Jane Smith",
                advisors: "Prof. Johnson",
                additionalInfo: "This structure won an award for its innovative design and sustainable features.",
                architecturalStyle: "Modern",
                mainPhoto: "1M",
                closeUp: "1C",
                isVisited: false,
                isOpened: false,
                recentlyVisited: -1,
                isLiked: false
            ),
            isDarkMode: .constant(false),
            onDismiss: {}
        )
    }
}
