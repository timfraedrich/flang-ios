import Foundation

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
