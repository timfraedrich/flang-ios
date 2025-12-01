public enum DailyGameMoveDuration: Hashable, CaseIterable, CustomStringConvertible {
    case oneDay
    case twoDays
    case threeDays
    
    var time: Int {
        switch self {
        case .oneDay: 1 * 24 * 60 * 60 * 1000
        case .twoDays: 2 * 24 * 60 * 60 * 1000
        case .threeDays: 3 * 24 * 60 * 60 * 1000
        }
    }
    
    public var description: String {
        Formatting.formatMilliseconds(time)
    }
}
