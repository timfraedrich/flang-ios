import SwiftUI

struct GameView: View {
    
    @State private var gameState = GameState()
    @State private var rotateBoard = false
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                infoAndControls(isFirstPlayerPerspective: false).rotationEffect(.degrees(180))
                ZStack {
                    BoardView(gameState: gameState, rotateBlackPieces: true)
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
                closeAction: { try? gameState.reset() },
                shareAction: {},
                rotateBoardAction: { rotateBoard.toggle() },
                backwardAction: { try? gameState.back() },
                forwardAction: { try? gameState.forward() }
            )
        }
        
    }
    
    struct Action: Equatable, Hashable {
        let name: String
        let symbolName: String
        let action: () -> Void
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(symbolName)
        }
        
        static func == (rhs: Self, lhs: Self) -> Bool {
            return rhs.name == lhs.name && rhs.symbolName == lhs.symbolName
        }
    }
}

#Preview {
    GameView()
}
