import Foundation

struct OnlineLiveGameRequestParameters: Codable, Sendable {
    
    let allowBots: Bool
    let timeout: Int
    let isRated: Bool
    let infiniteTime: Bool
    let time: Int
    let timeIncrement: Int?
    let range: Int?
    
    init(allowBots: Bool, timeout: Int, isRated: Bool, infiniteTime: Bool, time: Int, timeIncrement: Int?, range: Int?) {
        self.allowBots = allowBots
        self.timeout = timeout
        self.isRated = isRated
        self.infiniteTime = infiniteTime
        self.time = time
        self.timeIncrement = timeIncrement
        self.range = range
    }
}
