import Foundation

public struct OnlineGameConfiguration: Codable, Sendable {
    public let infiniteTime: Bool
    public let time: Int
    public let timeIncrement: Int?
    public let isRated: Bool
    
    public init(infiniteTime: Bool, time: Int, timeIncrement: Int?, isRated: Bool) {
        self.infiniteTime = infiniteTime
        self.time = time
        self.timeIncrement = timeIncrement
        self.isRated = isRated
    }
}
