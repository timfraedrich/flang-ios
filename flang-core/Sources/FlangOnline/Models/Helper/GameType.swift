public enum GameType: Hashable, CaseIterable, CustomStringConvertible {
    case live
    case daily
    
    // TODO: Localize
    public var description: String {
        switch self {
        case .live: "Live"
        case .daily: "Daily"
        }
    }
}
