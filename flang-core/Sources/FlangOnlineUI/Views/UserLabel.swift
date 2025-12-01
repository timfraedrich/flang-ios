import FlangOnline
import SwiftUI

public struct UserLabel: View {
    
    @Environment(\.font) private var font: Font?
    @Environment(\.fontResolutionContext) private var fontContext: Font.Context
    
    private let username: String
    private let title: String?
    private let isBot: Bool
    
    private var safeFont: Font { font ?? .body }
    private var badgeFont: Font { safeFont.scaled(by: 0.65) }
    private var spacing: CGFloat { safeFont.resolve(in: fontContext).pointSize * 0.35 }
    
    public init(username: String, title: String? = nil, isBot: Bool = false) {
        self.username = username
        self.title = title
        self.isBot = isBot
    }
    
    public init(playerInfo: PlayerInfo) {
        self.init(username: playerInfo.username, title: playerInfo.title, isBot: playerInfo.isBot)
    }
    
    public init(userInfo: UserInfo) {
        self.init(username: userInfo.username, title: userInfo.title, isBot: userInfo.isBot)
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            Text(username).bold()
            if let title = title, !title.isEmpty {
                badge(title).foregroundStyle(.green)
            }
            if isBot {
                badge(String(localized: "user_badge_bot", bundle: .module)).foregroundStyle(.blue)
            }
        }
    }
    
    @ViewBuilder
    private func badge(_ verbatim: String) -> some View {
        Text(verbatim: verbatim)
            .font(badgeFont.weight(.bold))
            .padding(.horizontal, spacing)
            .padding(.vertical, spacing / 2)
            .background(.foreground.opacity(0.2))
            .clipShape(.rect(cornerRadius: spacing))
    }
}

struct PlayerLabelPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            UserLabel(playerInfo: PreviewInstances.playerInfo).font(.largeTitle)
            UserLabel(playerInfo: PreviewInstances.gmPlayerInfo).font(.title)
            UserLabel(playerInfo: PreviewInstances.botPlayerInfo)
        }
    }
}
