import Foundation

public struct RatingHistoryEntry: Codable, Sendable {
    public let type: RatingType
    public let rating: Double
    public let date: Date
    
    public init(type: RatingType, rating: Double, date: Date) {
        self.type = type
        self.rating = rating
        self.date = date
    }
    
    private enum CodingKeys: CodingKey {
        case type
        case rating
        case date
    }
    
    public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<RatingHistoryEntry.CodingKeys> = try decoder.container(keyedBy: RatingHistoryEntry.CodingKeys.self)
        type = try container.decode(RatingType.self, forKey: RatingHistoryEntry.CodingKeys.type)
        rating = try container.decode(Double.self, forKey: RatingHistoryEntry.CodingKeys.rating)
        let timestamp = try container.decode(Int.self, forKey: RatingHistoryEntry.CodingKeys.date)
        date = .init(unixTimestamp: timestamp)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container: KeyedEncodingContainer<RatingHistoryEntry.CodingKeys> = encoder.container(keyedBy: RatingHistoryEntry.CodingKeys.self)
        try container.encode(type, forKey: RatingHistoryEntry.CodingKeys.type)
        try container.encode(rating, forKey: RatingHistoryEntry.CodingKeys.rating)
        try container.encode(date.unixTimestamp, forKey: RatingHistoryEntry.CodingKeys.date)
    }
}
