import FlangOnline
import SwiftUI

public struct GameHistoryRow: View {
    
    private let gameInfo: OnlineGameInfo
    private let currentUsername: String
    
    private var isWhite: Bool { gameInfo.white.username == currentUsername }
    private var opponent: PlayerInfo { isWhite ? gameInfo.black : gameInfo.white }
    private var didWin: Bool { if gameInfo.won > 0 { isWhite } else { !isWhite } }
    
    public init(game: OnlineGameInfo, currentUsername: String) {
        self.gameInfo = game
        self.currentUsername = currentUsername
    }

    public var body: some View {
        HStack(spacing: 12) {
            stateIndicator
            gameInfoView
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder private var stateIndicator: some View {
        VStack {
            if !gameInfo.running {
                if gameInfo.won == 0 {
                    Image(systemName: "minus").foregroundStyle(.gray)
                } else if didWin {
                    Image(systemName: "checkmark").foregroundStyle(.green)
                } else {
                    Image(systemName: "xmark").foregroundStyle(.red)
                }
            } else {
                Image(systemName: "record").foregroundStyle(.blue)
            }
        }
        .symbolVariant(.circle.fill)
        .frame(width: 30)
        .font(.title3)
    }
    
    @ViewBuilder private var gameInfoView: some View {
        HStack(spacing: 4) {
            UserInfoView(
                username: opponent.username,
                title: opponent.title,
                isBot: opponent.isBot,
                rating: opponent.rating,
                alignment: .leading
            )
            .font(.subheadline)
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                RelativeDateText(gameInfo.lastAction)
                    .font(.caption.weight(.semibold))
                HStack {
                    if gameInfo.configuration.isRated {
                        Text("Rated").foregroundStyle(.orange)
                    }
                    Text("Moves: \(gameInfo.moves)")
                }
                .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
    }
}

struct GameHistoryRowPreview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {                
                Section {
                    NavigationLink(value: "") {
                        GameHistoryRow(game: PreviewInstances.finishedOnlineGameInfo, currentUsername: PreviewInstances.playerInfo.username)
                    }
                    NavigationLink(value: "") {
                        GameHistoryRow(game: PreviewInstances.runningOnlineGameInfo, currentUsername: PreviewInstances.playerInfo.username)
                    }
                }
            }
        }
    }
}
