public enum RatingType: String, Codable, Hashable, Sendable {
    case classical
    case blitz
    case bullet
    case puzzle
    case daily
    case undefined
    
    public var description: String {
        switch self {
        case .classical: "Classical"
        case .blitz: "Blitz"
        case .bullet: "Bullet"
        case .puzzle: "Puzzle"
        case .daily: "Daily"
        default: "Undefined"
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

