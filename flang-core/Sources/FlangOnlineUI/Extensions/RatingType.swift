import FlangOnline
import SwiftUI

public extension RatingType {
    
    var color: Color {
        switch self {
        case .blitz: .blue
        case .bullet: .red
        case .classical: .green
        case .puzzle: .orange
        default: .gray
        }
    }
}
