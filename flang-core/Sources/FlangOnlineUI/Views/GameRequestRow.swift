import FlangOnline
import SwiftUI

public struct GameRequestRow: View {
    
    private let requester: UserInfo
    private let gameConfiguration: OnlineGameConfiguration
    private let isLiveGame: Bool
    private let userIsRequester: Bool
    private let action: () -> Void
    
    public init(
        requester: UserInfo,
        gameConfiguration: OnlineGameConfiguration,
        isLiveGame: Bool,
        userIsRequester: Bool,
        action: @escaping () -> Void
    ) {
        self.requester = requester
        self.gameConfiguration = gameConfiguration
        self.isLiveGame = isLiveGame
        self.userIsRequester = userIsRequester
        self.action = action
    }
    
    public init(liveRequest: OnlineLiveGameRequest, action: @escaping () -> Void) {
        self.init(
            requester: liveRequest.requester,
            gameConfiguration: liveRequest.configuration,
            isLiveGame: true,
            // Live game must be immediately accepted by another user
            userIsRequester: false,
            action: action
        )
    }
    
    public init(dailyRequest: OnlineDailyGameRequest, userIsRequester: Bool, action: @escaping () -> Void) {
        self.init(
            requester: dailyRequest.requester,
            gameConfiguration: dailyRequest.configuration,
            isLiveGame: false,
            userIsRequester: userIsRequester,
            action: action
        )
    }
    
    public var body: some View {
        HStack {
            UserInfoView(userInfo: requester, alignment: .leading)
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                let formattedDuration = Formatting.formatMilliseconds(gameConfiguration.time)
                Group {
                    if isLiveGame {
                        if let increment = gameConfiguration.timeIncrement, increment > 0 {
                            let formattedIncrement = Formatting.formatMilliseconds(increment)
                            Text(formattedDuration + " + " + formattedIncrement)
                        } else {
                            Text(formattedDuration)
                        }
                    } else {
                        Text("daily_game_duration_\(formattedDuration)", bundle: .module)
                    }
                }
                .font(.caption)
                Text(gameConfiguration.isRated ? "game_config_rated" : "game_config_casual", bundle: .module)
                    .font(.caption2)
                    .foregroundStyle(gameConfiguration.isRated ? .orange : .secondary)
            }
            Group {
                if userIsRequester {
                    Button(action: action) {
                        Text("game_request_cancel", bundle: .module)
                    }.tint(.red)
                } else {
                    Button(action: action) {
                        Text("game_request_accept", bundle: .module)
                    }
                }
            }
            .buttonStyle(.glassProminent)
            .font(.caption.weight(.semibold))
        }
    }
}

struct GameRequestRowPreview: PreviewProvider {
    static var previews: some View {
        List {
            GameRequestRow(liveRequest: PreviewInstances.liveGameRequest, action: {})
            GameRequestRow(dailyRequest: PreviewInstances.dailyGameRequest, userIsRequester: true, action: {})
        }
    }
}
