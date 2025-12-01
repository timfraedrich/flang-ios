import FlangModel
import FlangUI
import SwiftUI

struct GameScene: View {
    
    @Environment(\.dismiss) private var dismissAction
    @State private var gameState: GameState
    @State private var perspective: BoardView.Perspective = .multiplayerWhite
    @State private var showShareSheet = false
    @State private var showAbortConfimation = false
    
    init(game: Game = .init()) {
        self.gameState = .init(game: game)
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                controls(isFirstPlayerPerspective: false)
                GameView(gameState: gameState, perspective: perspective)
                    .backgroundStyle(.background.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                controls(isFirstPlayerPerspective: true)
            }
            .padding(.top, max(proxy.safeAreaInsets.top, 20))
            .padding(.bottom, max(proxy.safeAreaInsets.bottom, 20))
            .ignoresSafeArea()
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden()
        .alert("share", isPresented: $showShareSheet) {
            Button("share_game") {
                UIPasteboard.general.string = try? gameState.game.toFMN()
            }
            Button("share_board") {
                UIPasteboard.general.string = gameState.game.toFBN()
            }
            Button("cancel", role: .cancel) { }
        } message: {
            Text("share_clipboard_message")
        }
        .alert("abort", isPresented: $showAbortConfimation) {
            Button("abort", role: .destructive, action: dismissAction.callAsFunction)
        } message: {
            Text("abort_game_message")
        }
    }
    
    @ViewBuilder
    private func controls(isFirstPlayerPerspective: Bool) -> some View {
        GameControls(
            isFirstPlayerPerspective: isFirstPlayerPerspective,
            backEnabled: gameState.game.backEnabled,
            forwardEnabled: gameState.game.forwardEnabled,
            closeAction: {
                if gameState.game.hasHistory {
                    showAbortConfimation = true
                } else {
                    dismissAction()
                }
            },
            shareAction: { showShareSheet = true },
            rotateBoardAction: { perspective.rotate() },
            backwardAction: { try? gameState.back() },
            forwardAction: { try? gameState.forward() }
        )
        .rotationEffect(.degrees(isFirstPlayerPerspective ? 0 : 180))
    }
}

#Preview {
    GameScene()
}
