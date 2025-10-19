import Foundation
import Observation

@Observable
class GameState {
    var board: Board
    var moveGenerator: MoveGenerator
    var selectedPosition: BoardPosition?
    var legalMoves: Set<BoardPosition> = []

    init() {
        var newBoard = Board()
        newBoard.setupDefaultPosition()
        self.board = newBoard
        self.moveGenerator = MoveGenerator(board: newBoard)
    }

    // Get piece at position for UI display
    func getPiece(at position: BoardPosition) -> Piece? {
        let index = Board.index(x: position.col, y: position.row)
        let state = board.get(at: index)
        let type = state.type
        guard type != .none else { return nil }
        let pieceType = state.type
        let color = state.color
        let frozen = state.frozen
        return Piece(type: pieceType, color: color, frozen: frozen)
    }

    // Handle position selection and moves
    func selectPosition(_ position: BoardPosition) {
        let index = Board.index(x: position.col, y: position.row)
        // If no piece is selected
        if selectedPosition == nil {
            // Select this position if it has a piece of the current player's color
            let state = board.get(at: index)
            let type = state.type
            guard type != .none else { return }
            guard state.color == board.atMove else { return }
            // Don't allow selecting frozen pieces
            guard !state.frozen else { return }
            selectedPosition = position
            calculateLegalMoves(for: index)
        }
        // If a piece is already selected
        else if let selected = selectedPosition {
            let selectedIndex = Board.index(x: selected.col, y: selected.row)
            // If tapping the same position, deselect
            if selected == position {
                selectedPosition = nil
                legalMoves.removeAll()
            }
            // If tapping another piece of the same color, switch selection
            else if let piece = getPiece(at: position), piece.color == board.atMove, !piece.frozen {
                selectedPosition = position
                calculateLegalMoves(for: index)
            }
            // If tapping a legal move destination, make the move
            else if legalMoves.contains(position) {
                makeMove(from: selectedIndex, to: index)
                selectedPosition = nil
                legalMoves.removeAll()
            }
            // Otherwise, deselect
            else {
                selectedPosition = nil
                legalMoves.removeAll()
            }
        }
    }

    // Calculate legal moves for a piece
    private func calculateLegalMoves(for index: Board.Index) {
        legalMoves.removeAll()
        let state = board.get(at: index)
        let moves = moveGenerator.generateMovesForPiece(at: index, state: state)
        for move in moves {
            let position = BoardPosition(row: Board.y(of: move.to), col: Board.x(of: move.to))
            legalMoves.insert(position)
        }
    }

    // Make a move
    private func makeMove(from: Board.Index, to: Board.Index) {
        let state = board.get(at: from)
        let color = state.color
        let move = Move(
            from: from,
            to: to,
            fromPieceState: state,
            toPieceState: board.get(at: to),
            previouslyFrozenPieceIndex: board.frozenPieceIndex(for: color)
        )
        board.executeMove(move)
        moveGenerator.board = board // Update reference
    }

    // Check if game is over
    func isGameOver() -> Bool {
        return board.gameIsComplete()
    }

    // Get winner if game is over
    func getWinner() -> PieceColor? {
        if board.hasWon(color: .white) {
            .white
        } else if board.hasWon(color: .black) {
            .black
        } else {
            nil
        }
    }

    // Reset game
    func reset() {
        board = Board()
        board.setupDefaultPosition()
        moveGenerator = MoveGenerator(board: board)
        selectedPosition = nil
        legalMoves.removeAll()
    }
}
