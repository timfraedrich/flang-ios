public enum LiveGameTimeIncrement: Hashable, CaseIterable, CustomStringConvertible {
    case zero
    case oneSecond
    case twoSeconds
    case threeSeconds
    case fiveSeconds
    case tenSeconds
    
    var increment: Int {
        switch self {
        case .zero: 0
        case .oneSecond: 1000
        case .twoSeconds: 2 * 1000
        case .threeSeconds: 3 * 1000
        case .fiveSeconds: 5 * 1000
        case .tenSeconds: 10 * 1000
        }
    }
    
    public var description: String {
        Formatting.formatMilliseconds(increment)
    }
}
