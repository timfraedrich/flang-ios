import Foundation

enum PieceType: RawRepresentable {
    
    case none
    case pawn
    case horse
    case rook
    case flanger
    case uni
    case king
    
    var rawValue: UInt8 {
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

    var imageName: String? {
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
    var hasFreeze: Bool {
        return self != .king
    }
    
    init(rawValue: UInt8) {
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

enum PieceColor: RawRepresentable {
    case white
    case black
    
    var rawValue: Bool {
        switch self {
        case .white: true
        case .black: false
        }
    }
    
    init?(rawValue: Bool) {
        self = if rawValue { .white } else { .black }
    }
    
    var opponent: PieceColor { self == .white ? .black : .white }
}

struct Piece: Identifiable, Equatable {
    
    let id = UUID()
    let type: PieceType
    let color: PieceColor
    var frozen: Bool

    // Full image name for the piece (e.g., "wp", "bk")
    var imageName: String? {
        guard let imageName = type.imageName else { return nil }
        let colorPrefix = color == .white ? "w" : "b"
        return "\(colorPrefix)\(imageName)"
    }

    init(type: PieceType, color: PieceColor, frozen: Bool = false) {
        self.type = type
        self.color = color
        self.frozen = frozen
    }
}
