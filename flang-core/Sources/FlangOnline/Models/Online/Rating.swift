import Foundation

public struct Rating: Codable, Sendable {
    public let type: RatingType
    public let value: Double
    
    public init(type: RatingType, value: Double) {
        self.type = type
        self.value = value
    }
    
    private enum CodingKeys: CodingKey {
        case type
        case rating
    }
    
    public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<Rating.CodingKeys> = try decoder.container(keyedBy: Rating.CodingKeys.self)
        type = try container.decode(RatingType.self, forKey: Rating.CodingKeys.type)
        value = try container.decode(Double.self, forKey: Rating.CodingKeys.rating)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container: KeyedEncodingContainer<Rating.CodingKeys> = encoder.container(keyedBy: Rating.CodingKeys.self)
        try container.encode(type, forKey: Rating.CodingKeys.type)
        try container.encode(value, forKey: Rating.CodingKeys.rating)
    }
}
