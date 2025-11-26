import Foundation

struct OpeningQueryResponse: Codable {
    let result: [OpeningMove]
    let games: [OnlineGameInfo]
}
