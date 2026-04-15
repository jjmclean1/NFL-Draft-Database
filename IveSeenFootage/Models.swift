//
//  Models.swift
//  IveSeenFootage
//
//  Created by Julian Mclean on 4/14/26.
//

import SwiftUI

import Foundation

// MARK: - Data Models
struct Play: Identifiable, Hashable {
    let id = UUID()
    let description: String
    let videoID: String
    let startTime: Int
    let endTime: Int
    
    // Filter tags extracted from the data
    let isTouchdown: Bool
    let isFirstDown: Bool
    let airYards: Int
}

enum PlayFilter: String, CaseIterable {
    case all = "All Plays"
    case touchdowns = "Touchdowns"
    case firstDowns = "1st Downs"
    case explosive = "20+ Yds"
}

