import Foundation

public struct PlayerInfo: Codable, Sendable {
    public let username: String
    /// Negative rating indicates uncertainty - show as positive with ?
    public let rating: Double
    public let ratingDifference: Double
    public let time: Int
    public let isBot: Bool
    public let title: String?
    
    public init(username: String, rating: Double, ratingDifference: Double, time: Int, isBot: Bool, title: String? = nil) {
        self.username = username
        self.rating = rating
        self.ratingDifference = ratingDifference
        self.time = time
        self.isBot = isBot
        self.title = title
    }
    
    private enum CodingKeys: CodingKey {
        case username
        case rating
        case ratingDiff
        case time
        case isBot
        case title
    }
    
    public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<PlayerInfo.CodingKeys> = try decoder.container(keyedBy: PlayerInfo.CodingKeys.self)
        username = try container.decode(String.self, forKey: PlayerInfo.CodingKeys.username)
        rating = try container.decode(Double.self, forKey: PlayerInfo.CodingKeys.rating)
        ratingDifference = try container.decode(Double.self, forKey: PlayerInfo.CodingKeys.ratingDiff)
        time = try container.decode(Int.self, forKey: PlayerInfo.CodingKeys.time)
        isBot = try container.decode(Bool.self, forKey: PlayerInfo.CodingKeys.isBot)
        title = try container.decodeIfPresent(String.self, forKey: PlayerInfo.CodingKeys.title)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container: KeyedEncodingContainer<PlayerInfo.CodingKeys> = encoder.container(keyedBy: PlayerInfo.CodingKeys.self)
        try container.encode(username, forKey: PlayerInfo.CodingKeys.username)
        try container.encode(rating, forKey: PlayerInfo.CodingKeys.rating)
        try container.encode(ratingDifference, forKey: PlayerInfo.CodingKeys.ratingDiff)
        try container.encode(time, forKey: PlayerInfo.CodingKeys.time)
        try container.encode(isBot, forKey: PlayerInfo.CodingKeys.isBot)
        try container.encodeIfPresent(title, forKey: PlayerInfo.CodingKeys.title)
    }
}
