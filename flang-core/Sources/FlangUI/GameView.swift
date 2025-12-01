import SwiftUI
import FlangModel

public struct GameView: View {
    
    @Bindable private var gameState: GameState
    private let perspective: BoardView.Perspective
    
    public init(gameState: GameState, perspective: BoardView.Perspective = .multiplayerWhite) {
        self.gameState = gameState
        self.perspective = perspective
    }
    
    public var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                atMoveIndicator(isFirstPlayerPerspective: false)
                ZStack {
                    BoardView(gameState: gameState, perspective: perspective)
                        .frame(width: proxy.size.width, height: proxy.size.width)
                        .disabled(gameState.winner != nil)
                    if let winner = gameState.winner {
                        Text("game_end_win_\(winner.localized)", bundle: .module)
                            .font(.largeTitle.bold())
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                atMoveIndicator(isFirstPlayerPerspective: true)
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func atMoveIndicator(isFirstPlayerPerspective: Bool) -> some View {
        Capsule()
            .fill(.tint)
            .frame(height: 4)
            .opacity((gameState.atMove == perspective.firstPlayerColor) == isFirstPlayerPerspective ? 1 : 0)
    }
}

#Preview {
    GameView(gameState: .init())
        .padding()
        .backgroundStyle(.background.secondary)
}
