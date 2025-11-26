import FlangOnline
import SwiftUI

public struct UserInfoView: View {
    
    @Environment(\.font) private var font: Font?
    @Environment(\.fontResolutionContext) private var fontContext: Font.Context
    
    private let username: String
    private let title: String?
    private let isBot: Bool
    private let rating: Double
    private let ratingDifference: Double?
    private let alignment: HorizontalAlignment
    
    private var safeFont: Font { font ?? .body }
    private var ratingFont: Font { safeFont.scaled(by: 0.7) }
    
    public init(
        username: String,
        title: String? = nil,
        isBot: Bool = false,
        rating: Double,
        ratingDifference: Double? = nil,
        alignment: HorizontalAlignment = .center
    ) {
        self.username = username
        self.title = title
        self.isBot = isBot
        self.rating = rating
        self.ratingDifference = ratingDifference
        self.alignment = alignment
    }
    
    public init(playerInfo: PlayerInfo, alignment: HorizontalAlignment = .center) {
        self.init(
            username: playerInfo.username,
            title: playerInfo.title,
            isBot: playerInfo.isBot,
            rating: playerInfo.rating,
            ratingDifference: playerInfo.ratingDifference,
            alignment: alignment
        )
    }
    
    public init(userInfo: UserInfo, alignment: HorizontalAlignment = .center) {
        self.init(
            username: userInfo.username,
            title: userInfo.title,
            isBot: userInfo.isBot,
            rating: userInfo.rating,
            ratingDifference: nil,
            alignment: alignment
        )
    }

    public var body: some View {
        VStack(alignment: alignment, spacing: 4) {
            UserLabel(username: username, title: title, isBot: isBot)
            RatingLabel(rating: rating, ratingDifference: ratingDifference)
                .font(ratingFont)
                .foregroundStyle(.secondary)
        }
    }
}

struct PlayerInfoViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            UserInfoView(playerInfo: PreviewInstances.playerInfo).font(.largeTitle)
            UserInfoView(playerInfo: PreviewInstances.botPlayerInfo).font(.title)
            UserInfoView(playerInfo: PreviewInstances.gmPlayerInfo)
        }
    }
}
