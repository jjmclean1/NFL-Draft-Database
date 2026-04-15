//
//  HighlightService.swift
//  IveSeenFootage
//
//  Created by Julian Mclean on 4/14/26.
//

import SwiftUI
import Foundation

enum ServiceError: Error {
    case fileNotFound
    case decodingError(Error)
    case invalidData
}

class HighlightService {
    static let shared = HighlightService()
    private init() {}
    
    
    func getPlays() throws -> [Play] {
        do {
            //local JSON for now
            guard let url = Bundle.main.url(forResource: "TysonPlays", withExtension: "json") else {
                throw ServiceError.fileNotFound
            }
            
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
                        let rawArray = try decoder.decode([[String: String]].self, from: data)
            
            let plays = rawArray.compactMap { dict -> Play? in
                let vStart = dict["v_time"] ?? "[00:00]"
                let vEnd = dict["v_end"] ?? "[00:10]"
                let desc = dict["description"] ?? ""
                
                let start = timeToSeconds(vStart)
                var end = timeToSeconds(vEnd)
                
                if end <= start { end = start + 8 }
                
                return Play(
                    description: desc.replacingOccurrences(of: "⭐ TYSON | ", with: ""),
                    videoID: dict["videoID"] ?? "pULZVS4U3OI",
                    startTime: start,
                    endTime: end,
                    isTouchdown: desc.contains("TD") || desc.contains("Touchdown"),
                    isFirstDown: desc.contains("1ST down") || desc.contains("1st Down"),
                    airYards: extractYards(from: desc)
                )
            }
            return plays
            
        } catch {
            throw ServiceError.decodingError(error)
        }
    }
    
    func getPlayById(id: UUID, from plays: [Play]) -> Play? {
        return plays.first(where: { $0.id == id })
    }
    
    private func timeToSeconds(_ timestamp: String) -> Int {
        let clean = timestamp.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        let parts = clean.split(separator: ":")
        guard parts.count == 2, let mins = Int(parts[0]), let secs = Int(parts[1]) else { return 0 }
        return (mins * 60) + secs
    }
    
    private func extractYards(from text: String) -> Int {
        let pattern = #"(\d+)yds"#
        if let range = text.range(of: pattern, options: .regularExpression) {
            let yardString = text[range].replacingOccurrences(of: "yds", with: "")
            return Int(yardString) ?? 0
        }
        return 0
    }
}
