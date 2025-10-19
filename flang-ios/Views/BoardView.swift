import SwiftUI

struct BoardView: View {
    
    @Bindable var gameState: GameState

    var body: some View {
        VStack(spacing: .zero) {
            ForEach((.zero..<Board.boardSize).reversed(), id: \.self) { row in
                HStack(spacing: .zero) {
                    ForEach(.zero..<Board.boardSize, id: \.self) { col in
                        let pos = BoardPosition(row: row, col: col)
                        SquareView(
                            position: pos,
                            piece: gameState.getPiece(at: pos),
                            isSelected: gameState.selectedPosition == pos,
                            isLegalMove: gameState.legalMoves.contains(pos)
                        )
                        .onTapGesture { gameState.selectPosition(pos) }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    BoardView(gameState: .init()).padding()
}
