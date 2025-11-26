import Foundation

public enum PieceColor: RawRepresentable, Hashable, Sendable {
    case white
    case black
    
    public var rawValue: Bool {
        switch self {
        case .white: true
        case .black: false
        }
    }
    
    public init?(rawValue: Bool) {
        self = if rawValue { .white } else { .black }
    }
    
    public var opponent: PieceColor { self == .white ? .black : .white }
}
