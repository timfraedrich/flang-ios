public enum LiveGamePreset: Hashable, CaseIterable, CustomStringConvertible {
    case bulletOneZero
    case bulletTwoOne
    case blitzThree
    case blitzFive
    case rapid
    case classical
    
    // TODO: Localize
    public var description: String {
        switch self {
        case .bulletOneZero: "Bullet (1 min)"
        case .bulletTwoOne: "Bullet (2+1)"
        case .blitzThree: "Blitz (3 min)"
        case .blitzFive: "Blitz (5 min)"
        case .rapid: "Rapid (10 min)"
        case .classical: "Classical (30 min)"
        }
    }
    
    public var duration: LiveGameDuration {
        switch self {
        case .bulletOneZero: .oneMinute
        case .bulletTwoOne: .twoMinutes
        case .blitzThree: .threeMinutes
        case .blitzFive: .fiveMinutes
        case .rapid: .tenMinutes
        case .classical: .thirtyMinutes
        }
    }
    
    public var increment: LiveGameTimeIncrement {
        switch self {
        case .bulletOneZero, .blitzThree, .blitzFive, .rapid, .classical: .zero
        case .bulletTwoOne: .oneSecond
        }
    }
}
