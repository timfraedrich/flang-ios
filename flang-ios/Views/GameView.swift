import SwiftUI

struct GameView: View {
    
    @Environment(\.dismiss) private var dismissAction
    @State private var gameState = GameState()
    @State private var rotateBoard = false
    @State private var showShareSheet = false
    @State private var showAbortConfimation = false
    private let rotateBlackPieces: Bool
    
    init(gameState: GameState = .init(), rotateBlackPieces: Bool = true) {
        self.gameState = gameState
        self.rotateBlackPieces = rotateBlackPieces
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                infoAndControls(isFirstPlayerPerspective: false).rotationEffect(.degrees(180))
                ZStack {
                    BoardView(gameState: gameState, rotateBlackPieces: rotateBlackPieces)
                        .frame(width: proxy.size.width, height: proxy.size.width)
                        .rotationEffect(.degrees(rotateBoard ? 180 : 0))
                        .disabled(gameState.winner != nil)
                    if let winner = gameState.winner {
                        Text("\(winner == .black ? "Black" : "White") won!")
                            .font(.largeTitle.bold())
                            .frame(width: proxy.size.width, height: proxy.size.width)
                            .transition(.push(from: .leading))
                    }
                }
                infoAndControls(isFirstPlayerPerspective: true)
            }
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden()
        .alert("Share", isPresented: $showShareSheet) {
            Button("Share Game") {
                UIPasteboard.general.string = try? gameState.game.toFMN()
            }
            Button("Share Board") {
                UIPasteboard.general.string = gameState.game.toFBN()
            }
            Text("Cancel")
        } message: {
            Text("The game or board will be copied to your clipboard in text form.")
        }
        .alert("Abort", isPresented: $showAbortConfimation) {
            Button("Abort", role: .destructive, action: dismissAction.callAsFunction)
        } message: {
            Text("Do you want to abort the game? All progress will be lost unless the game was backed up somewhere.")
        }
    }
    
    @ViewBuilder
    func infoAndControls(isFirstPlayerPerspective: Bool) -> some View {
        VStack {
            HStack {
                Spacer()
                Circle()
                    .fill(gameState.game.atMove == .white ? .white : .black)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(.gray, lineWidth: 1)
                    )
                Text(gameState.game.atMove == .white ? "White" : "Black")
            }
            .padding()
            Spacer()
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
                rotateBoardAction: { rotateBoard.toggle() },
                backwardAction: { try? gameState.back() },
                forwardAction: { try? gameState.forward() }
            )
        }
        
    }
}

#Preview {
    GameView()
}
