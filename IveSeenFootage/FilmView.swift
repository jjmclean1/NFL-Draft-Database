import SwiftUI

struct FilmView: View {
    let prospect: Prospect
    let bgDark = Color(red: 0.03, green: 0.05, blue: 0.08)
    var teamSecondary: Color { Color(hex: prospect.secondaryColorHex) }
    
    @State private var allPlays: [Play] = []
    @State private var selectedFilter: PlayFilter = .all
    @State private var currentPlay: Play?
    
    var filteredPlays: [Play] {
        switch selectedFilter {
        case .all: return allPlays
        case .touchdowns: return allPlays.filter { $0.isTouchdown }
        case .firstDowns: return allPlays.filter { $0.isFirstDown }
        case .explosive: return allPlays.filter { $0.airYards >= 20 }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let play = currentPlay {
                YouTubePlayerView(videoID: play.videoID, startTime: play.startTime, endTime: play.endTime)
                    .frame(height: 230)
                    .id(play.id)
            } else {
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 230)
                    .overlay(
                        VStack(spacing: 8) {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: teamSecondary))
                            Text("INITIALIZING FILM TERMINAL...")
                                .font(.custom("MicrogrammaD-BoldExte", size: 8))
                                .foregroundColor(teamSecondary)
                        }
                    )
            }
                    HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(prospect.firstName.uppercased()) \(prospect.lastName.uppercased())")
                        .font(.custom("MicrogrammaD-BoldExte", size: 16))
                        .foregroundColor(.white)
                    Text("\(prospect.position) • \(prospect.teamName)")
                        .font(.custom("MicrogrammaD-BoldExte", size: 10))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            .background(bgDark)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PlayFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter,
                            accentColor: teamSecondary
                        ) {
                            selectedFilter = filter
                            
                            switch filter {
                            case .all:
                                currentPlay = allPlays.first
                            case .touchdowns:
                                currentPlay = allPlays.first(where: { $0.isTouchdown })
                            case .firstDowns:
                                currentPlay = allPlays.first(where: { $0.isFirstDown })
                            case .explosive:
                                currentPlay = allPlays.first(where: { $0.airYards >= 20 })
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 12)
            .background(bgDark)
            
            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredPlays) { play in
                        PlayRowView(play: play, isPlaying: currentPlay?.id == play.id, accentColor: teamSecondary)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                currentPlay = play
                            }
                        Rectangle().fill(Color.white.opacity(0.05)).frame(height: 1)
                    }
                }
            }
            .background(bgDark)
        }
        .onAppear {
            do {
                self.allPlays = try HighlightService.shared.getPlays()
                self.currentPlay = self.allPlays.first
            } catch {
                print("Failed to load plays: \(error)")
            }
        }
    }
}

struct FilterChip: View {
    var title: String
    var isSelected: Bool
    var accentColor: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("MicrogrammaD-BoldExte", size: 10))
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(isSelected ? accentColor.opacity(0.1) : Color.white.opacity(0.03))
                .foregroundColor(isSelected ? accentColor : .gray)
                .border(isSelected ? accentColor : Color.white.opacity(0.1))
        }
    }
}

struct PlayRowView: View {
    var play: Play
    var isPlaying: Bool
    var accentColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Rectangle()
                    .fill(isPlaying ? accentColor.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 40, height: 40)
                    .border(isPlaying ? accentColor : Color.clear)
                
                Image(systemName: isPlaying ? "play.fill" : "video")
                    .foregroundColor(isPlaying ? accentColor : .gray)
                    .font(.system(size: 12))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(play.description)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(isPlaying ? .white : .gray)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    if play.isTouchdown { BadgeView(text: "TD", color: .red) }
                    if play.isFirstDown { BadgeView(text: "1ST_DOWN", color: .orange) }
                    BadgeView(text: "AIR:\(play.airYards)YDS", color: .gray)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isPlaying ? Color.white.opacity(0.02) : Color.clear)
    }
}

struct BadgeView: View {
    var text: String
    var color: Color
    
    var body: some View {
        Text(text)
            .font(.custom("MicrogrammaD-BoldExte", size: 10))
            .padding(.horizontal, 6).padding(.vertical, 3)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .border(color.opacity(0.5))
    }
}
