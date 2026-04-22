import SwiftUI

let dummyProspect = Prospect(
    firstName: "Jordyn", lastName: "Tyson", position: "WR", number: 9,
    teamName: "Arizona State",
    height: "6'1 3/4\"", weight: "203lbs", age: 21,
    bio: "An explosive outside receiver with historic deep-ball tracking.",
    headshotURL: "https://a.espncdn.com/combiner/i?img=/i/headshots/college-football/players/full/4880281.png&w=350&h=254",
    teamLogoURL: "https://a.espncdn.com/i/teamlogos/ncaa/500/9.png",
    primaryColorHex: "8C2248", secondaryColorHex: "FFC226",
    adjImpact: 99, yacAbility: 95, separation: 88, runBlock: 65, pressRel: 82,
    targets: 87, receptions: 61, receivingYards: 711, receivingTouchdowns: 7,
    routesRun: 273, yardsPerGame: 70.0,
    targetShare: 0.227, ADOT: 14.2, catchRate: 0.536, contestedCatchRate: 0.441,
    contestedTargetRate: 0.168, dropRate: 0.044, yardsAfterCatchperReception: 4.9,
    slotRate: 0.279, wideRate: 0.716, yardsPerRouteRun: 2.20, yardsPerTarget: 6.9,
    handSize: "9 1/8\"", fortyYardDash: "4.46", verticalJump: "N/A",
    broadJump: "N/A", twentyYardShuttle: "N/A", threeCone: "N/A",
    gameLogs: nil, seasonStats: nil, comparisonData: nil
)

struct MainTabView: View {
    @State private var activeTab: ArcadeTab = .search
    let bgDark = Color(red: 0.02, green: 0.03, blue: 0.05)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch activeTab {
                case .search:
                    SearchView()
                case .draft:
                    Text("DRAFT DB LOADING...")
                        .font(.custom("MicrogrammaD-BoldExte", size: 24))
                        .foregroundColor(Color(red: 0.10, green: 0.90, blue: 0.80))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(bgDark)
                case .compare:
                    Text("COMPARE MATRIX LOADING...")
                        .font(.custom("MicrogrammaD-BoldExte", size: 24))
                        .foregroundColor(Color(red: 1.00, green: 0.50, blue: 0.00))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(bgDark)
                case .visits:
                    Text("VISITS LOG LOADING...")
                        .font(.custom("MicrogrammaD-BoldExte", size: 24))
                        .foregroundColor(Color(red: 1.00, green: 0.10, blue: 0.15))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(bgDark)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            ArcadeNavigationBar(activeTab: $activeTab)
        }
        .preferredColorScheme(.dark)
        .edgesIgnoringSafeArea(.bottom)
    }
}
enum ArcadeTab: String, CaseIterable {
    case search = "SEARCH"
    case draft = "DRAFT"
    case compare = "COMPARE"
    case visits = "VISITS"
    
    var icon: String {
        switch self {
        case .search: return "magnifyingglass"
        case .draft: return "list.clipboard.fill"
        case .compare: return "square.grid.3x3.fill"
        case .visits: return "airplane"
        }
    }
    
    var color: Color {
        switch self {
        case .search: return Color(red: 0.10, green: 0.90, blue: 0.80)
        case .draft: return Color(red: 1.00, green: 0.85, blue: 0.00)
        case .compare: return Color(red: 1.00, green: 0.10, blue: 0.15)
        case .visits: return Color(red: 0.15, green: 0.30, blue: 0.95)
        }
    }
}

struct ArcadeNavigationBar: View {
    @Binding var activeTab: ArcadeTab
    let barBg = Color(red: 0.10, green: 0.12, blue: 0.16)
    let pixelFont = "MicrogrammaD-BoldExte"
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ArcadeTab.allCases, id: \.self) { tab in
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        activeTab = tab
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(activeTab == tab ? tab.color : Color.white.opacity(0.3))
                            .shadow(color: activeTab == tab ? tab.color.opacity(0.8) : .clear, radius: 4, x: 0, y: 0)
                        
                        Text(tab.rawValue)
                            .font(.custom(pixelFont, size: 10))
                            .foregroundColor(activeTab == tab ? .white : Color.white.opacity(0.3))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, activeTab == tab ? 12 : 16)
                    .padding(.bottom, activeTab == tab ? 34 : 30)
                    .background(
                        ZStack {
                            if activeTab == tab {
                                Color.black.opacity(0.4)
                                Rectangle()
                                    .fill(tab.color)
                                    .frame(height: 3)
                                    .shadow(color: tab.color, radius: 3)
                                    .frame(maxHeight: .infinity, alignment: .top)
                            }
                        }
                    )
                }
            }
        }
        .background(barBg)
        .overlay(Rectangle().stroke(Color.white.opacity(0.1), lineWidth: 2))
        .shadow(color: Color.black.opacity(0.8), radius: 10, x: 0, y: -5)
    }
}

struct SearchView: View {
    let bgDark = Color(red: 0.02, green: 0.03, blue: 0.05)
    let jamTeal = Color(red: 0.10, green: 0.90, blue: 0.80)
    let pixelFont = "MicrogrammaD-BoldExte"
    
    @State private var searchText = ""
    @State private var navToPlayer = false
    
    let mockPlayers = [dummyProspect]
    
    var filteredPlayers: [Prospect] {
        if searchText.isEmpty {
            return mockPlayers
        } else {
            return mockPlayers.filter {
                $0.firstName.lowercased().contains(searchText.lowercased()) ||
                $0.lastName.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                bgDark.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("Draft Stock")
                            .font(.custom(pixelFont, size: 24))
                            .foregroundColor(jamTeal)
                            .shadow(color: jamTeal.opacity(0.6), radius: 8, x: 0, y: 0)
                        
                        Spacer()
                            Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.clear)
                    }
                    .padding(.horizontal, 20).padding(.bottom, 12).padding(.top, 12)
                    .background(
                        bgDark.edgesIgnoringSafeArea(.top)
                            .overlay(Rectangle().fill(jamTeal).frame(height: 3), alignment: .bottom)
                    )
                    
                    //search bar
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(jamTeal)
                        
                        TextField("ENTER PROSPECT ID...", text: $searchText)
                            .font(.custom(pixelFont, size: 12))
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        if !searchText.isEmpty {
                            Button("CLEAR") {
                                searchText = ""
                            }
                            .font(.custom(pixelFont, size: 10))
                            .foregroundColor(Color.gray)
                        }
                    }
                    .padding(16)
                    .background(Color(red: 0.08, green: 0.10, blue: 0.15))
                    .border(Color.white.opacity(0.1), width: 2)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                    
                    //list pl;ayers
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredPlayers, id: \.id) { player in
                                //navigation link it
                                NavigationLink(destination: PlayerProfileView(prospect: player)) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: player.primaryColorHex).opacity(0.2))
                                                .frame(width: 52, height: 52)
                                            
                                            Circle()
                                                .stroke(Color(hex: player.primaryColorHex), lineWidth: 1.5)
                                                .frame(width: 52, height: 52)
                                            
                                            AsyncImage(url: URL(string: player.headshotURL)) { phase in
                                                if let image = phase.image {
                                                    image.resizable().scaledToFill()
                                                } else {
                                                    Text(String(player.firstName.prefix(1)))
                                                        .font(.custom(pixelFont, size: 18))
                                                        .foregroundColor(jamTeal)
                                                }
                                            }
                                            .frame(width: 48, height: 48)
                                            .clipShape(Circle())
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(player.firstName) \(player.lastName)".uppercased())
                                                .font(.custom(pixelFont, size: 14))
                                                .foregroundColor(.white)
                                            
                                            Text("\(player.position) • \(player.teamName)".uppercased())
                                                .font(.system(size: 10, design: .monospaced))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 20)
                                    .background(Color.white.opacity(0.01))
                                }
                                Rectangle()
                                    .fill(Color.white.opacity(0.05))
                                    .frame(height: 1)
                                    .padding(.leading, 84)
                            }
                        }
                        .padding(.bottom, 120)
                    }
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}
