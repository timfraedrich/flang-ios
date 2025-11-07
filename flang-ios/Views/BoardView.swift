import SwiftUI

struct BoardView: View {
    
    @Bindable var gameState: GameState
    let rotateBlackPieces: Bool

    var body: some View {
        VStack(spacing: .zero) {
            ForEach((.zero..<Board.boardSize).reversed(), id: \.self) { row in
                HStack(spacing: .zero) {
                    ForEach(.zero..<Board.boardSize, id: \.self) { col in
                        let pos = BoardPosition(row: row, col: col)
                        ZStack {
                            let piece = gameState.getPiece(at: pos)
                            SquareView(
                                position: pos,
                                isFrozen: piece?.frozen ?? false,
                                hasPiece: piece != nil,
                                isSelected: gameState.selectedPosition == pos,
                                isLegalMove: gameState.legalMoves.contains(pos)
                            )
                            PieceView(piece: piece).rotationEffect(.degrees(rotateBlackPieces && piece?.color == .black ? 180 : 0))
                        }
                        .onTapGesture { gameState.selectPosition(pos) }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    BoardView(gameState: .init(), rotateBlackPieces: true).padding()
}
