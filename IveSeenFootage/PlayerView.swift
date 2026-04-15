import SwiftUI
import WebKit

// MARK: - Data Models

// MARK: - Main Player View
struct PlayerView: View {
    let playerName = "Jordyn Tyson"
    let school = "Arizona State"
    
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
            // 1. YouTube Video Player
            if let play = currentPlay {
                YouTubePlayerView(videoID: play.videoID, startTime: play.startTime, endTime: play.endTime)
                    .frame(height: 230)
                    // CRITICAL: Using play.id ensures the WebView dies and reloads on every tap
                    .id(play.id)
            } else {
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 230)
                    .overlay(Text("Loading Tape...").foregroundColor(.white))
            }
            
            // 2. Header Section
            HStack {
                VStack(alignment: .leading) {
                    Text(playerName).font(.title).bold()
                    Text("WR • \(school)").font(.subheadline).foregroundColor(.secondary)
                }
                Spacer()
                Text("\(filteredPlays.count) Clips")
                    .font(.caption).bold()
                    .padding(6)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding()
            
            // 3. Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(PlayFilter.allCases, id: \.self) { filter in
                        FilterChip(title: filter.rawValue, isSelected: selectedFilter == filter) {
                            withAnimation { selectedFilter = filter }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 10)
            
            Divider()
            
            // 4. The Tape List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredPlays) { play in
                        PlayRowView(play: play, isPlaying: currentPlay?.id == play.id)
                            .contentShape(Rectangle()) // Makes the entire row hit-testable
                            .onTapGesture {
                                print("DEBUG: Selected play at \(play.startTime)")
                                currentPlay = play
                            }
                        Divider()
                    }
                }
            }
        }
        .onAppear {
                    do {
                        self.allPlays = try HighlightService.shared.getPlays()
                        self.currentPlay = self.allPlays.first
                    } catch {
                        print("❌ Failed to load plays: \(error)")
                    }
                }
        }
    }

// MARK: - Helper Components

struct FilterChip: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline).fontWeight(.medium)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct PlayRowView: View {
    var play: Play
    var isPlaying: Bool
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: isPlaying ? "play.circle.fill" : "video.fill")
                .foregroundColor(isPlaying ? .blue : .gray)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(play.description)
                    .font(.subheadline)
                    .fontWeight(isPlaying ? .semibold : .regular)
                    .lineLimit(2)
                
                HStack {
                    if play.isTouchdown { BadgeView(text: "TD", color: .red) }
                    if play.isFirstDown { BadgeView(text: "1st Down", color: .orange) }
                    BadgeView(text: "\(play.airYards)yds", color: .gray)
                }
            }
            Spacer()
        }
        .padding()
        .background(isPlaying ? Color.blue.opacity(0.05) : Color.clear)
    }
}

struct BadgeView: View {
    var text: String
    var color: Color
    var body: some View {
        Text(text).font(.caption2).bold()
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(color.opacity(0.1)).foregroundColor(color).cornerRadius(4)
    }
}

#Preview {
    PlayerView()
}
// Note: Ensure YouTubePlayerView is defined once in your project to avoid redeclaration errors.

#Preview {
    PlayerView()
}
