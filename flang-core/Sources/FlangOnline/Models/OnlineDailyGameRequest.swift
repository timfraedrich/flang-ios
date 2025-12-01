import Foundation

public struct OnlineDailyGameRequest: Codable, Sendable {
    public let id: Int
    public let configuration: OnlineGameConfiguration
    public let requester: UserInfo
    public let dateCreated: Date
    
    public init(id: Int, configuration: OnlineGameConfiguration, requester: UserInfo, dateCreated: Date) {
        self.id = id
        self.configuration = configuration
        self.requester = requester
        self.dateCreated = dateCreated
    }
    
    private enum CodingKeys: CodingKey {
        case id
        case configuration
        case requester
        case dateCreated
    }
    
    public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<OnlineDailyGameRequest.CodingKeys> = try decoder.container(keyedBy: OnlineDailyGameRequest.CodingKeys.self)
        id = try container.decode(Int.self, forKey: OnlineDailyGameRequest.CodingKeys.id)
        configuration = try container.decode(OnlineGameConfiguration.self, forKey: OnlineDailyGameRequest.CodingKeys.configuration)
        requester = try container.decode(UserInfo.self, forKey: OnlineDailyGameRequest.CodingKeys.requester)
        let dateCreatedTimestamp = try container.decode(Int.self, forKey: OnlineDailyGameRequest.CodingKeys.dateCreated)
        dateCreated = Date(unixTimestamp: dateCreatedTimestamp)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container: KeyedEncodingContainer<OnlineDailyGameRequest.CodingKeys> = encoder.container(keyedBy: OnlineDailyGameRequest.CodingKeys.self)
        try container.encode(id, forKey: OnlineDailyGameRequest.CodingKeys.id)
        try container.encode(configuration, forKey: OnlineDailyGameRequest.CodingKeys.configuration)
        try container.encode(requester, forKey: OnlineDailyGameRequest.CodingKeys.requester)
        try container.encode(dateCreated.unixTimestamp, forKey: OnlineDailyGameRequest.CodingKeys.dateCreated)
    }
}
