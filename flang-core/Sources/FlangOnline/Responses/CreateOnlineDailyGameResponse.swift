import Foundation

public enum CreateOnlineDailyGameResponse: Decodable {
    
    case requestCreated(requestId: Int)
    case gameStarted(gameId: Int)
    
    private enum CodingKeys: CodingKey {
        case gameId
        case requestId
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let gameId = try? container.decode(Int.self, forKey: CodingKeys.gameId) {
            self = .gameStarted(gameId: gameId)
        } else if let requestId = try? container.decode(Int.self, forKey: CodingKeys.requestId) {
            self = .requestCreated(requestId: requestId)
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [CodingKeys.gameId, .requestId],
                debugDescription: "Could not find either 'gameId' or 'requestId' in encoded payload."
            ))
        }
    }
}
