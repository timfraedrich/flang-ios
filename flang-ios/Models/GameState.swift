import Foundation
import Observation

@Observable
class GameState {

    var game: Game
    var selectedPosition: BoardPosition?
    var legalMoves: Set<BoardPosition> = []
    
    var board: Board { game.board }
    var atMove: PieceColor { game.atMove }
    var winner: PieceColor? { game.winner }

    init(game: Game = .init()) {
        self.game = game
    }
    
    func getPiece(at position: BoardPosition) -> Piece? {
        let index = Board.index(x: position.col, y: position.row)
        guard let piece = board[index], piece.type != .none else { return nil }
        return piece
    }

    // MARK: - Move Selection & Execution
    
    func selectPosition(_ position: BoardPosition) {
        let index = Board.index(x: position.col, y: position.row)
        // If no piece is selected
        if selectedPosition == nil {
            // Select this position if it has a piece of the current player's color
            guard let piece = board[index], piece.type != .none else { return }
            guard piece.color == atMove else { return }
            // Don't allow selecting frozen pieces
            guard !piece.frozen else { return }
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
            else if let piece = getPiece(at: position), piece.color == atMove, !piece.frozen {
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
    
    private func calculateLegalMoves(for index: Board.Index) {
        legalMoves.removeAll()
        let targets = game.legalTargets(for: index)
        for targetIndex in targets {
            let position = BoardPosition(row: Board.y(of: targetIndex), col: Board.x(of: targetIndex))
            legalMoves.insert(position)
        }
    }
    
    private func makeMove(from: Board.Index, to: Board.Index) {
        let action = Action.move(from: from, to: to)
        try? game.perform(action)
    }

    // MARK: - Game Control
    
    func reset() throws {
        try game.reset()
        resetShownMoves()
    }
    
    func back() throws {
        try game.back()
        resetShownMoves()
    }
    
    func forward() throws {
        try game.forward()
        resetShownMoves()
    }

    func resign() throws {
        let action = Action.resign(color: atMove)
        try game.perform(action)
        resetShownMoves()
    }
    
    private func resetShownMoves() {
        selectedPosition = nil
        legalMoves.removeAll()
    }
}
