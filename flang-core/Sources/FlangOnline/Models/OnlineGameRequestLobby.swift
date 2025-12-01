import Foundation

public struct OnlineGameRequestLobby: Codable, Sendable {
    public let liveRequests: [OnlineLiveGameRequest]
    public let dailyRequests: [OnlineDailyGameRequest]
    
    public init(liveRequests: [OnlineLiveGameRequest], dailyRequests: [OnlineDailyGameRequest]) {
        self.liveRequests = liveRequests
        self.dailyRequests = dailyRequests
    }
}
