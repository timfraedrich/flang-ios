import SwiftUI

public enum LiveGamePreset: Hashable, CaseIterable {
    case bulletOneZero
    case bulletTwoOne
    case blitzThree
    case blitzFive
    case rapid
    case classical
    
    public var localized: String {
        switch self {
        case .bulletOneZero: .init(localized: "bullet_1m", bundle: .module)
        case .bulletTwoOne: .init(localized: "bullet_2m_1s", bundle: .module)
        case .blitzThree: .init(localized: "blitz_3m", bundle: .module)
        case .blitzFive: .init(localized: "blitz_5m", bundle: .module)
        case .rapid: .init(localized: "rapid_10m", bundle: .module)
        case .classical: .init(localized: "classical_30m", bundle: .module)
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
