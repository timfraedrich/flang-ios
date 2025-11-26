import FlangOnline
import SwiftUI

public struct PlayerInfoView: View {
    
    private let playerInfo: PlayerInfo
    private let lastUpdate: Date
    private let playerIsAtMove: Bool
    private let gameIsRunning: Bool
    
    public init(playerInfo: PlayerInfo, lastUpdate: Date, playerIsAtMove: Bool = false, gameIsRunning: Bool = false) {
        self.playerInfo = playerInfo
        self.lastUpdate = lastUpdate
        self.playerIsAtMove = playerIsAtMove
        self.gameIsRunning = gameIsRunning
    }

    public var body: some View {
        HStack {
            UserInfoView(playerInfo: playerInfo, alignment: .leading).font(.body)
            Spacer()
            Group {
                if playerIsAtMove, gameIsRunning {
                    TimelineView(.animation) { context in
                        Text(formatTimer(for: context.date))
                            .contentTransition(.numericText())
                            .animation(.smooth, value: context.date)
                    }
                } else {
                    Text(formatTimer(for: lastUpdate))
                }
            }
            .font(.title3.weight(.semibold))
            .monospacedDigit()
        }
        .padding()
        .background()
        .clipShape(.containerRelative)
        .overlay {
            if playerIsAtMove {
                ContainerRelativeShape()
                    .strokeBorder(style: .init(lineWidth: 3))
                    .foregroundStyle(.tint.opacity(0.5))
            }
        }
    }

    private func formatTimer(for date: Date) -> AttributedString {
        let timeLeftAtReferenceDate = TimeInterval(playerInfo.time) / 1000
        let referenceDate = playerIsAtMove ? lastUpdate : date
        let endDate = referenceDate.addingTimeInterval(timeLeftAtReferenceDate)
        let range = referenceDate..<endDate
        let lastMinute = referenceDate.distance(to: endDate) < 60
        var attributedString = SystemFormatStyle.Timer(countingDownIn: range).format(date)
        if lastMinute {
            attributedString.foregroundColor = .red
        }
        return attributedString
    }
}

struct OnlineGamePlayerInfoViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            PlayerInfoView(playerInfo: PreviewInstances.playerInfo, lastUpdate: .now, playerIsAtMove: true, gameIsRunning: true)
            PlayerInfoView(playerInfo: PreviewInstances.botPlayerInfo, lastUpdate: .now, playerIsAtMove: false, gameIsRunning: false)
            PlayerInfoView(playerInfo: PreviewInstances.gmPlayerInfo, lastUpdate: .now, playerIsAtMove: false, gameIsRunning: true)
        }
        .backgroundStyle(.background.secondary)
        .containerShape(.rect(cornerRadius: 24))
    }
}
