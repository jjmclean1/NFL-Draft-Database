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
                    isFirstDown: desc.contains("1ST down") || desc.contains("1st Down") || desc.contains("1st down"),
                    airYards: extractYards(from: desc)
                )
            }
            
            if plays.isEmpty { throw ServiceError.invalidData }
            return plays
            
        } catch {
            print("JSON Failed (\(error)). Loading safety fallback data.")
            return [
                Play(description: "34yd Catch vs. Northern Arizona", videoID: "pULZVS4U3OI", startTime: 11, endTime: 18, isTouchdown: false, isFirstDown: true, airYards: 34),
                Play(description: "Tunnel Screen TD", videoID: "pULZVS4U3OI", startTime: 54, endTime: 66, isTouchdown: true, isFirstDown: true, airYards: -2),
                Play(description: "Sideline Contested Catch", videoID: "pULZVS4U3OI", startTime: 200, endTime: 210, isTouchdown: false, isFirstDown: true, airYards: 24),
                Play(description: "Redzone Slant TD", videoID: "pULZVS4U3OI", startTime: 425, endTime: 433, isTouchdown: true, isFirstDown: true, airYards: 8)
            ]
        }
    }
    
    func getPlayById(id: UUID, from plays: [Play]) -> Play? {
        return plays.first(where: { $0.id == id })
    }
    private func timeToSeconds(_ timestamp: String) -> Int {
        let clean = timestamp.replacingOccurrences(of: "[", with: "")
                             .replacingOccurrences(of: "]", with: "")
                             .trimmingCharacters(in: .whitespaces)
        let parts = clean.split(separator: ":")
        
        if parts.count == 2, let mins = Int(parts[0]), let secs = Int(parts[1]) {
            return (mins * 60) + secs
        } else if parts.count == 1, let secs = Int(parts[0]) {
            return secs
        }
        return 0
    }
    
    private func extractYards(from text: String) -> Int {
        let pattern = #"(\d+)\s*yds"#
        if let range = text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
            let yardString = text[range].replacingOccurrences(of: "yds", with: "", options: .caseInsensitive).trimmingCharacters(in: .whitespaces)
            return Int(yardString) ?? 0
        }
        return 0
    }
}
