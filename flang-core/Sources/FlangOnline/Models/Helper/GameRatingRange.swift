public enum GameRatingRange: Hashable, CaseIterable, CustomStringConvertible {
    case oneHundred
    case twoHundred
    case threeHundred
    case fourHundred
    case fiveHundred
    case infinite
    
    var range: Int {
        switch self {
        case .oneHundred: 100
        case .twoHundred: 200
        case .threeHundred: 300
        case .fourHundred: 400
        case .fiveHundred: 500
        case .infinite: -1
        }
    }
    
    public var description: String {
        switch self {
        case .infinite: "∞"
        default: "±\(self.range)"
        }
    }
}
