import SwiftUI

public enum RatingType: String, Codable, Hashable, Sendable {
    case classical
    case blitz
    case bullet
    case puzzle
    case daily
    case undefined
    
    public var localized: String {
        switch self {
        case .classical: .init(localized: "rating_type_classical", bundle: .module)
        case .blitz: .init(localized: "rating_type_blitz", bundle: .module)
        case .bullet: .init(localized: "rating_type_bullet", bundle: .module)
        case .puzzle: .init(localized: "rating_type_puzzle", bundle: .module)
        case .daily: .init(localized: "rating_type_daily", bundle: .module)
        default: .init(localized: "rating_type_undefined", bundle: .module)
        }
    }
    
    public var rawValue: String {
        switch self {
        case .classical: "classical"
        case .blitz: "blitz"
        case .bullet: "bullet"
        case .puzzle: "puzzle"
        case .daily: "daily"
        default: "undefined"
        }
    }
    
    public init(rawValue: String) {
        self = switch rawValue {
        case "classical": .classical
        case "blitz": .blitz
        case "bullet": .bullet
        case "puzzle": .puzzle
        case "daily": .daily
        default: .undefined
        }
    }
    
    public init(from decoder: any Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        self.init(rawValue: rawValue)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

