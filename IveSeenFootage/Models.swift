import SwiftUI
import Foundation

struct Play: Identifiable, Hashable {
    let id = UUID()
    let description: String
    let videoID: String
    let startTime: Int
    let endTime: Int
    
    let isTouchdown: Bool
    let isFirstDown: Bool
    let airYards: Int
}

enum PlayFilter: String, CaseIterable {
    case all = "ALL PLAYS"
    case touchdowns = "TOUCHDOWNS"
    case firstDowns = "1ST DOWNS"
    case explosive = "20+ YDS"
}

struct GameLog: Identifiable, Codable {
    var id = UUID()
    let date: String
    let opponent: String
    let snaps: Int
    let targets: Int
    let receptions: Int
    let yards: Int
    let touchdowns: Int
    let yac: Int
    let drops: Int
    
    enum CodingKeys: String, CodingKey {
        case date, opponent, snaps, targets, receptions, yards, touchdowns, yac, drops
    }
}

struct SeasonStat: Identifiable, Codable {
    var id = UUID()
    let year: String
    let team: String
    let conf: String
    let gamesPlayed: Int
    
    let receptions: Int
    let recYards: Int
    let recTD: Int
    
    let rushingAtt: Int
    let rushingYards: Int
    let rushingTD: Int
    
    let totalPlays: Int
    let totalYards: Int
    let totalTD: Int
    
    enum CodingKeys: String, CodingKey {
        case year, team, conf, gamesPlayed, receptions, recYards, recTD, rushingAtt, rushingYards, rushingTD, totalPlays, totalYards, totalTD
    }
}

struct Prospect: Identifiable, Codable {
    var id = UUID()
    
    let firstName: String
    let lastName: String
    let position: String
    let number: Int
    let teamName: String
    let height: String
    let weight: String
    let age: Int
    let bio: String
    
    let headshotURL: String
    let teamLogoURL: String
    let primaryColorHex: String
    let secondaryColorHex: String
    
    let adjImpact: Int
    let yacAbility: Int
    let separation: Int
    let runBlock: Int
    let pressRel: Int
    
    let targets: Int
    let receptions: Int
    let receivingYards: Int
    let receivingTouchdowns: Int
    let routesRun: Int
    let yardsPerGame: Double
    
    let targetShare: Double
    let ADOT: Double
    let catchRate: Double
    let contestedCatchRate: Double
    let contestedTargetRate: Double
    let dropRate: Double
    let yardsAfterCatchperReception: Double
    let slotRate: Double
    let wideRate: Double
    let yardsPerRouteRun: Double
    let yardsPerTarget: Double
    
    let handSize: String
    let fortyYardDash: String
    let verticalJump: String
    let broadJump: String
    let twentyYardShuttle: String
    let threeCone: String
        let gameLogs: [GameLog]?
    let seasonStats: [SeasonStat]?
    let comparisonData: [String: [String: Double]]?
    
    func value(for statKey: String) -> Double {
        switch statKey {
        case "Receptions": return Double(receptions)
        case "Yards": return Double(receivingYards)
        case "TDs": return Double(receivingTouchdowns)
        case "Yards/RR": return yardsPerRouteRun
        case "Target Rate": return contestedTargetRate
        case "Catch Rate": return contestedCatchRate
        case "Drop %": return dropRate
        case "YAC/R": return yardsAfterCatchperReception
        default: return 0.0
        }
    }
        enum CodingKeys: String, CodingKey {
        case firstName, lastName, position, number, teamName, height, weight, age, bio
        case headshotURL, teamLogoURL, primaryColorHex, secondaryColorHex
        case adjImpact, yacAbility, separation, runBlock, pressRel
        case targets, receptions, receivingYards, receivingTouchdowns, routesRun, yardsPerGame
        case targetShare, ADOT, catchRate, contestedCatchRate, contestedTargetRate, dropRate
        case yardsAfterCatchperReception, slotRate, wideRate, yardsPerRouteRun, yardsPerTarget
        case handSize, fortyYardDash, verticalJump, broadJump, twentyYardShuttle, threeCone
        case gameLogs, seasonStats, comparisonData
    }
}

extension Color {
    static let gold = Color(red: 0.96, green: 0.77, blue: 0.08)
    static let teal90s = Color(red: 0.00, green: 0.61, blue: 0.67)
    static let deepBlack = Color(red: 0.05, green: 0.05, blue: 0.05)
    static let cardBlack = Color(red: 0.09, green: 0.09, blue: 0.09)
    
    static let jamTeal   = Color(red: 0.25, green: 0.73, blue: 0.65)
    static let jamRed    = Color(red: 1.00, green: 0.10, blue: 0.15)
    static let jamYellow = Color(red: 1.00, green: 0.85, blue: 0.00)
    static let jamBlue   = Color(red: 0.15, green: 0.30, blue: 0.95)
    static let jamOrange = Color(red: 1.00, green: 0.50, blue: 0.00)
    static let jamBlack  = Color(red: 0.02, green: 0.03, blue: 0.05)

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}
