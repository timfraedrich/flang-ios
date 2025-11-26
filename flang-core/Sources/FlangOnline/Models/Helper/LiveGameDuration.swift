public enum LiveGameDuration: Hashable, CaseIterable, CustomStringConvertible {
    case thirtySeconds
    case oneMinute
    case twoMinutes
    case threeMinutes
    case fiveMinutes
    case tenMinutes
    case fifteenMinutes
    case twentyMinutes
    case thirtyMinutes
    case oneHour
    
    var time: Int {
        switch self {
        case .thirtySeconds: 30 * 1000
        case .oneMinute: 60 * 1000
        case .twoMinutes: 2 * 60 * 1000
        case .threeMinutes: 3 * 60 * 1000
        case .fiveMinutes: 5 * 60 * 1000
        case .tenMinutes: 10 * 60 * 1000
        case .fifteenMinutes: 15 * 60 * 1000
        case .twentyMinutes: 20 * 60 * 1000
        case .thirtyMinutes: 30 * 60 * 1000
        case .oneHour: 60 * 60 * 1000
        }
    }
    
    public var description: String {
        Formatting.formatMilliseconds(time)
    }
}
