import FlangOnline
import FlangUI
import SwiftUI

public struct OnlineGameView: View {

    @Bindable private var onlineGameState: OnlineGameState
    private let perspective: BoardView.Perspective
    private let onPlayerSelection: ((PlayerInfo) -> Void)?
    
    private func getPlayerInfos(for onlineGameInfo: OnlineGameInfo) -> (top: PlayerInfo, bottom: PlayerInfo) {
        let firstPlayerColor = perspective.firstPlayerColor
        return if firstPlayerColor == .white {
            (top: onlineGameInfo.black, bottom: onlineGameInfo.white)
        } else {
            (top: onlineGameInfo.white, bottom: onlineGameInfo.black)
        }
    }
    
    private func isBottomPlayerAtMove(for onlineGameState: OnlineGameState) -> Bool {
        perspective.firstPlayerColor == onlineGameState.atMove
    }

    public init(onlineGameState: OnlineGameState, perspective: BoardView.Perspective, onPlayerSelection: ((PlayerInfo) -> Void)? = nil) {
        self.onlineGameState = onlineGameState
        self.perspective = perspective
        self.onPlayerSelection = onPlayerSelection
    }

    public var body: some View {
        if let onlineGameInfo = onlineGameState.gameInfo {
            GeometryReader { proxy in
                VStack(spacing: 16) {
                    let (topPlayer, bottomPlayer) = getPlayerInfos(for: onlineGameInfo)
                    let isBottomPlayerAtMove = isBottomPlayerAtMove(for: onlineGameState)
                    Spacer()
                    PlayerInfoView(
                        playerInfo: topPlayer,
                        lastUpdate: onlineGameState.lastUpdate,
                        playerIsAtMove: !isBottomPlayerAtMove,
                        gameIsRunning: onlineGameInfo.running
                    )
                    .onTapGesture { onPlayerSelection?(topPlayer) }
                    board(for: onlineGameState, onlineGameInfo: onlineGameInfo)
                        .disabled(!onlineGameState.playerIsAtMove)
                        .frame(width: proxy.size.width, height: proxy.size.width)
                    PlayerInfoView(
                        playerInfo: bottomPlayer,
                        lastUpdate: onlineGameState.lastUpdate,
                        playerIsAtMove: isBottomPlayerAtMove,
                        gameIsRunning: onlineGameInfo.running
                    )
                    .onTapGesture { onPlayerSelection?(bottomPlayer) }
                    Spacer()
                }
                .containerShape(.rect(cornerRadius: 20))
                .padding(.top, max(proxy.safeAreaInsets.top, 20))
                .padding(.bottom, max(proxy.safeAreaInsets.bottom, 20))
                .ignoresSafeArea()
            }
        }
    }
    
    @ViewBuilder
    private func board(for onlineGameState: OnlineGameState, onlineGameInfo: OnlineGameInfo) -> some View {
        ZStack {
            BoardView(
                board: onlineGameState.board,
                selectedPosition: onlineGameState.selectedPosition,
                legalMoves: onlineGameState.legalMoves,
                perspective: perspective,
                onPositionTapped: { position in
                    Task {
                        try? await onlineGameState.selectPosition(position)
                    }
                }
            )
            Group {
                if let winner = onlineGameState.winner {
                    Text("\(winner == .black ? "Black" : "White") won!")
                } else if !onlineGameInfo.running && onlineGameState.winner == nil && !onlineGameState.forwardEnabled {
                    Text("Game Over - Draw")
                }
            }
            .font(.largeTitle.bold())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
