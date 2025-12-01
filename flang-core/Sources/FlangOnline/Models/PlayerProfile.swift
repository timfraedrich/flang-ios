import Foundation

public struct PlayerProfile: Codable, Sendable {
    
    public let username: String
    public let title: String?
    public let isBot: Bool
    public let isOnline: Bool
    public let registrationDate: Date
    public let completedGames: Int
    public let history: [RatingHistoryEntry]
    public let ratings: [Rating]
    
    public init(
        username: String,
        title: String?,
        isBot: Bool,
        isOnline: Bool,
        registrationDate: Date,
        completedGames: Int,
        history: [RatingHistoryEntry],
        ratings: [Rating]
    ) {
        self.username = username
        self.title = title
        self.isBot = isBot
        self.isOnline = isOnline
        self.registrationDate = registrationDate
        self.completedGames = completedGames
        self.history = history
        self.ratings = ratings
    }
    
    private enum CodingKeys: CodingKey {
        case username
        case title
        case isBot
        case online
        case registration
        case completedGames
        case history
        case ratings
    }
    
    public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<PlayerProfile.CodingKeys> = try decoder.container(keyedBy: PlayerProfile.CodingKeys.self)
        username = try container.decode(String.self, forKey: PlayerProfile.CodingKeys.username)
        title = try container.decodeIfPresent(String.self, forKey: PlayerProfile.CodingKeys.title)
        isBot = try container.decode(Bool.self, forKey: PlayerProfile.CodingKeys.isBot)
        isOnline = try container.decode(Bool.self, forKey: PlayerProfile.CodingKeys.online)
        let registrationTimestamp = try container.decode(Int.self, forKey: PlayerProfile.CodingKeys.registration)
        registrationDate = .init(unixTimestamp: registrationTimestamp)
        completedGames = try container.decode(Int.self, forKey: PlayerProfile.CodingKeys.completedGames)
        history = try container.decode([RatingHistoryEntry].self, forKey: PlayerProfile.CodingKeys.history)
        ratings = try container.decode([Rating].self, forKey: PlayerProfile.CodingKeys.ratings)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container: KeyedEncodingContainer<PlayerProfile.CodingKeys> = encoder.container(keyedBy: PlayerProfile.CodingKeys.self)
        try container.encode(username, forKey: PlayerProfile.CodingKeys.username)
        try container.encodeIfPresent(title, forKey: PlayerProfile.CodingKeys.title)
        try container.encode(isBot, forKey: PlayerProfile.CodingKeys.isBot)
        try container.encode(isOnline, forKey: PlayerProfile.CodingKeys.online)
        try container.encode(registrationDate.unixTimestamp, forKey: PlayerProfile.CodingKeys.registration)
        try container.encode(completedGames, forKey: PlayerProfile.CodingKeys.completedGames)
        try container.encode(history, forKey: PlayerProfile.CodingKeys.history)
        try container.encode(ratings, forKey: PlayerProfile.CodingKeys.ratings)
    }
}
