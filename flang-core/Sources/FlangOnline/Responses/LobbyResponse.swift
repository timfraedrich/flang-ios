import Foundation

struct LobbyResponse: Codable {
    let requests: [OnlineLiveGameRequest]
    let dailyRequests: [OnlineDailyGameRequest]
}
