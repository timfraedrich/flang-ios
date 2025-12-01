import SwiftUI

public enum GameType: Hashable, CaseIterable {
    case live
    case daily
    
    public var localized: String {
        switch self {
        case .live: .init(localized: "game_type_live", bundle: .module)
        case .daily: .init(localized: "game_type_daily", bundle: .module)
        }
    }
}
