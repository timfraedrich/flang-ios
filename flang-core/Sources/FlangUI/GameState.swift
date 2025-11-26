import FlangModel
import Foundation
import Observation

@Observable
public class GameState {

    public private(set) var game: Game
    public private(set) var selectedPosition: BoardPosition?
    public private(set) var legalMoves: Set<BoardPosition> = []
    
    public var board: Board { game.board }
    public var atMove: PieceColor { game.atMove }
    public var winner: PieceColor? { game.winner }
    public var backEnabled: Bool { game.backEnabled }
    public var forwardEnabled: Bool { game.forwardEnabled }

    public init(game: Game = .init()) {
        self.game = game
    }
    
    public func getPiece(at position: BoardPosition) -> Piece? {
        let piece = board.piece(at: position)
        guard piece.type != .none else { return nil }
        return piece
    }

    // MARK: - Move Selection & Execution
    
    public func selectPosition(_ position: BoardPosition) {
        // If no piece is selected
        if selectedPosition == nil {
            // Select this position if it has a piece of the current player's color
            let piece = board.piece(at: position)
            guard piece.type != .none else { return }
            guard piece.color == atMove else { return }
            // Don't allow selecting frozen pieces
            guard !piece.frozen else { return }
            selectedPosition = position
            calculateLegalMoves(for: position)
        }
        // If a piece is already selected
        else if let selected = selectedPosition {
            if selected == position {
                // If tapping the same position, deselect
                resetShownMoves()
            } else if let piece = getPiece(at: position), piece.color == atMove, !piece.frozen {
                // If tapping another piece of the same color, switch selection
                selectedPosition = position
                calculateLegalMoves(for: position)
            } else if legalMoves.contains(position) {
                // If tapping a legal move destination, make the move
                try? move(from: selected, to: position)
                resetShownMoves()
            } else {
                // Otherwise, deselect
                resetShownMoves()
            }
        }
    }
    
    private func calculateLegalMoves(for position: BoardPosition) {
        legalMoves.removeAll()
        legalMoves = Set(game.legalTargets(for: position))
    }

    // MARK: - Game Control
    
    public func reset() throws {
        try game.reset()
        resetShownMoves()
    }
    
    public func back() throws {
        try game.back()
        resetShownMoves()
    }
    
    public func forward() throws {
        try game.forward()
        resetShownMoves()
    }
    
    public func perform(_ action: Action) throws {
        try game.perform(action)
        resetShownMoves()
    }
    
    public func move(from: BoardPosition, to: BoardPosition) throws {
        try perform(.move(from: from, to: to))
        resetShownMoves()
    }

    public func resign() throws {
        try perform(.resign(color: atMove))
        resetShownMoves()
    }
    
    private func resetShownMoves() {
        selectedPosition = nil
        legalMoves.removeAll()
    }
}
