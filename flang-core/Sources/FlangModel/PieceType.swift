import Foundation

public enum PieceType: RawRepresentable, Sendable {
    
    case none
    case pawn
    case horse
    case rook
    case flanger
    case uni
    case king
    
    public var rawValue: UInt8 {
        switch self {
        case .none: 0
        case .pawn: 1
        case .horse: 2
        case .rook: 3
        case .flanger: 4
        case .uni: 5
        case .king: 6
        }
    }

    public var imageName: String? {
        switch self {
        case .none: nil
        case .pawn: "p"
        case .horse: "n"
        case .rook: "r"
        case .flanger: "f"
        case .uni: "q"
        case .king: "k"
        }
    }

    /// Piece freezes after moving.
    public var hasFreeze: Bool {
        return self != .king
    }

    /// Get the character representation for this piece type
    /// - Parameter color: The color determines case (white=uppercase, black=lowercase)
    /// - Returns: Single character representing the piece (P/p, R/r, H/h, F/f, U/u, K/k)
    public func character(for color: PieceColor) -> Character {
        let baseChar: Character = switch self {
        case .none: " "
        case .pawn: "P"
        case .horse: "H"
        case .rook: "R"
        case .flanger: "F"
        case .uni: "U"
        case .king: "K"
        }
        return color == .white ? baseChar : Character(baseChar.lowercased())
    }

    /// Parse a piece type from a character
    /// - Parameter char: The character to parse (P/p, R/r, H/h, F/f, U/u, K/k, or space)
    /// - Returns: The piece type, or nil if invalid
    public static func from(character char: Character) -> (type: PieceType, color: PieceColor)? {
        let color: PieceColor = char.isUppercase ? .white : .black
        let upper = char.uppercased().first!
        let type: PieceType? = switch upper {
        case "P": .pawn
        case "H": .horse
        case "R": .rook
        case "F": .flanger
        case "U": .uni
        case "K": .king
        case " ": PieceType.none
        default: nil
        }
        guard let type else { return nil }
        return (type, color)
    }

    public init(rawValue: UInt8) {
        self = switch rawValue {
        case 1: .pawn
        case 2: .horse
        case 3: .rook
        case 4: .flanger
        case 5: .uni
        case 6: .king
        default: .none
        }
    }
}
