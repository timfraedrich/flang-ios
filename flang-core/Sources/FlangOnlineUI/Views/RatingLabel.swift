import FlangOnline
import SwiftUI

public struct RatingLabel: View {
    
    @Environment(\.font) private var font: Font?
    @Environment(\.fontResolutionContext) private var fontContext: Font.Context
    
    private let rating: Double
    private let ratingDifference: Double?
    
    private var safeFont: Font { font ?? .body }
    private var spacing: CGFloat { safeFont.resolve(in: fontContext).pointSize * 0.35 }
    
    public init(rating: Double, ratingDifference: Double? = nil) {
        self.rating = rating
        self.ratingDifference = ratingDifference
    }
    
    public init(playerInfo: PlayerInfo) {
        self.init(rating: playerInfo.rating, ratingDifference: playerInfo.ratingDifference)
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            Text(formatRating(rating))
            if let ratingDifference, ratingDifference != .zero {
                Text(ratingDifference, format: .number.sign(strategy: .always()).precision(.fractionLength(0)))
                    .foregroundStyle(ratingDifference > 0 ? .green : .red)
            }
        }
    }
    
    private func formatRating(_ rating: Double) -> String {
        // Negative rating indicates uncertainty - show as positive with ?
        if rating < 0 {
            "\(Int(abs(rating)))?"
        } else {
            "\(Int(rating))"
        }
    }
}
