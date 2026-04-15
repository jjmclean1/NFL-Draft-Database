//
//  HomeView.swift
//  IveSeenFootage
//
//  Created by Julian Mclean on 4/2/26.
//

import SwiftUI

// MARK: - Dummy Data Models
struct NFLTeam: Identifiable {
    let id = UUID()
    let city: String
    let name: String
    let color: Color
}

struct Prospect: Identifiable {
    let id = UUID()
    let name: String
    let position: String
    let school: String
}

// MARK: - Main Home Screen
struct HomeView: View {
    @State private var searchText = ""
    
    // trash data
    let teams = [
        NFLTeam(city: "Carolina", name: "Panthers", color: .blue),
        NFLTeam(city: "Washington", name: "Commanders", color: .red),
        NFLTeam(city: "New England", name: "Patriots", color: .indigo),
        NFLTeam(city: "Arizona", name: "Cardinals", color: .red),
        NFLTeam(city: "Los Angeles", name: "Chargers", color: .cyan)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    
                    // 1. NFL Teams Horizontal Scroll
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Teams")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(teams) { team in
                                    NavigationLink(destination: TeamDetailView(team: team)) {
                                        TeamCircleView(team: team)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // 2. Top 50 Big Board Entry Point
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Draft Boards")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        NavigationLink(destination: BigBoardView()) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Top 50 Big Board")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Consensus rankings & film")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "list.number")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    
                    // 3. Browse by Position List
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Browse Film")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            PositionRowView(title: "Quarterbacks", icon: "target")
                            PositionRowView(title: "Wide Receivers", icon: "hands.sparkles.fill")
                            PositionRowView(title: "Edge Rushers", icon: "bolt.fill")
                            PositionRowView(title: "Offensive Line", icon: "shield.fill")
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 10)
            }
            .navigationTitle("Draft Vault")
            .searchable(text: $searchText, prompt: "Search players, teams...")
        }
    }
}

// MARK: - Subviews & Destinations

// View for inside the Teams list
struct TeamDetailView: View {
    var team: NFLTeam
    
    // Dummy prospects linked to this team
    let linkedProspects = [
        Prospect(name: "Jordyn Tyson", position: "WR", school: "Arizona State"),
        Prospect(name: "Will Campbell", position: "OT", school: "LSU")
    ]
    
    var body: some View {
        List {
            Section(header: Text("Pre-Draft Visits & Links")) {
                ForEach(linkedProspects) { prospect in
                    // This is where you will eventually route to your YouTubePlayerView
                    NavigationLink(destination: Text("\(prospect.name) Video Player Goes Here")) {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text("\(prospect.position) • \(prospect.school)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Section(header: Text("Team Needs")) {
                Text("1. Wide Receiver")
                Text("2. Offensive Tackle")
                Text("3. Cornerback")
            }
        }
        .navigationTitle(team.name)
    }
}

// View for the Top 50 List
struct BigBoardView: View {
    var body: some View {
        List {
            // Hardcoded preview of how the Top 50 will look
            BigBoardRowView(rank: 1, name: "Travis Hunter", position: "CB/WR", school: "Colorado")
            BigBoardRowView(rank: 2, name: "Will Campbell", position: "OT", school: "LSU")
            BigBoardRowView(rank: 3, name: "Tetairoa McMillan", position: "WR", school: "Arizona")
            BigBoardRowView(rank: 4, name: "Jordyn Tyson", position: "WR", school: "Arizona State")
            BigBoardRowView(rank: 5, name: "Mason Graham", position: "DT", school: "Michigan")
        }
        .navigationTitle("Top 50 Big Board")
    }
}

struct BigBoardRowView: View {
    var rank: Int
    var name: String
    var position: String
    var school: String
    
    var body: some View {
        HStack(spacing: 15) {
            Text("\(rank)")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                Text("\(position) • \(school)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

// Circular UI for the Horizontal Team Scroll
struct TeamCircleView: View {
    var team: NFLTeam
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(team.color.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                // Placeholder for actual NFL Logos
                Text(String(team.name.prefix(1)))
                    .font(.title)
                    .bold()
                    .foregroundColor(team.color)
            }
            
            Text(team.city)
                .font(.caption)
                .bold()
                .lineLimit(1)
        }
        .frame(width: 80)
    }
}

// The UI for the vertical list of positions
struct PositionRowView: View {
    var title: String
    var icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Rectangle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
                
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    HomeView()
}
