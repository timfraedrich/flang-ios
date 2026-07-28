import Foundation

public class MoveGenerator {
    
    public private(set) var board: Board
    public let includeOwnPieces: Bool
    public let ignoreFreeze: Bool

    public init(board: Board, includeOwnPieces: Bool = false, ignoreFreeze: Bool = false) {
        self.board = board
        self.includeOwnPieces = includeOwnPieces
        self.ignoreFreeze = ignoreFreeze
    }

    // MARK: - Public API
    
    public func updateBoard(_ board: Board) {
        self.board = board
    }

    /// Generate all legal moves for a color
    public func generateMoves(for color: PieceColor) -> [Action] {
        var moves: [Action] = []
        for position in Board.positions {
            let piece = board.piece(at: position)
            guard piece.type != .none, piece.color == color else { continue }
            let pieceMoves = generateMovesForPiece(at: position, state: piece)
            moves.append(contentsOf: pieceMoves)
        }
        return moves
    }

    /// Generate moves for a specific piece at an index
    public func generateMovesForPiece(at position: BoardPosition, state: Piece) -> [Action] {
        var moves: [Action] = []
        // Can't move frozen pieces (unless ignoring freeze)
        guard ignoreFreeze || !state.frozen else { return moves }
        for targetPosition in generateTargetPositions(from: position, state: state) {
            moves.append(.move(from: position, to: targetPosition))
        }

        return moves
    }

    /// Check if a specific action is legal
    public func isLegalMove(_ action: Action, for color: PieceColor) -> Bool {
        switch action {
        case .move(let from, let to):
            // Check if piece exists and is the right color
            let piece = board.piece(at: from)
            guard piece.type != .none, piece.color == color else { return false }
            // Check if piece is frozen
            if !ignoreFreeze && piece.frozen { return false }
            // Generate legal moves for this piece and check if 'to' is in the list
            let legalMoves = generateMovesForPiece(at: from, state: piece)
            return legalMoves.contains(.move(from: from, to: to))
        case .resign:
            // Resignation is always legal
            return true
        }
    }

    /// Get all legal target squares for a piece at a given position
    public func legalTargets(forPieceAt position: BoardPosition) -> [BoardPosition] {
        let piece = board.piece(at: position)
        guard piece.type != .none else { return [] }
        let moves = generateMovesForPiece(at: position, state: piece)
        return moves.compactMap { action in
            if case .move(_, let to) = action {
                to
            } else {
                nil
            }
        }
    }

    // MARK: - Private Helpers

    /// Generate target indices for a piece
    private func generateTargetPositions(from position: BoardPosition, state: Piece) -> [BoardPosition] {
        var targets: [BoardPosition] = []
        // Pawns and riders may move into a horse of the same color, so their moves need a separate target check
        if state.type.hasPawnMoves {
            targets.append(contentsOf: pawnTargets(from: position, color: state.color))
        }
        // A pawn has no moves besides its pawn moves
        if state.type != .pawn {
            targets.append(contentsOf: sequenceTargets(from: position, state: state))
        }
        return targets
    }

    /// Generate the targets of the pawn moves of a pawn or a rider
    private func pawnTargets(from position: BoardPosition, color: PieceColor) -> [BoardPosition] {
        var targets: [BoardPosition] = []
        for moveSequence in RelativePieceMoves.getMoveSequences(for: .pawn, and: color) {
            guard let vector = moveSequence.first,
                  let targetPosition = position + vector,
                  checkPawnTarget(at: targetPosition, color: color)
            else { continue }
            targets.append(targetPosition)
        }
        // Pawn dash: jump two squares forward when a pawn of the same color stands directly in front
        let direction = RelativePieceMoves.pawnDirection(for: color)
        if let frontPosition = position + (x: 0, y: direction),
           board.piece(at: frontPosition).type == .pawn,
           board.piece(at: frontPosition).color == color,
           let targetPosition = position + (x: 0, y: direction * 2),
           checkPawnTarget(at: targetPosition, color: color) {
            targets.append(targetPosition)
        }
        return targets
    }

    /// Generate the targets of the move sequences of a piece
    private func sequenceTargets(from position: BoardPosition, state: Piece) -> [BoardPosition] {
        var targets: [BoardPosition] = []
        let type = state.type
        let color = state.color
        let moveSequences = RelativePieceMoves.getMoveSequences(for: type, and: color)
        let hasDouble = RelativePieceMoves.hasDoubleMoves(type: type)
        var seenTargets: Set<BoardPosition> = []
        for moveSequence in moveSequences {
            for vector in moveSequence {
                // If target is invalid, stop this sequence (but continue with others)
                guard let targetPosition = position + vector, checkTarget(at: targetPosition, color: color) else { break }
                if hasDouble {
                    if !seenTargets.contains(targetPosition) {
                        seenTargets.insert(targetPosition)
                        targets.append(targetPosition)
                    }
                } else {
                    targets.append(targetPosition)
                }
                // Stop this sequence if we hit a piece (but continue with other sequences)
                guard isEmpty(at: targetPosition) else { break }
            }
        }
        return targets
    }
    
    /// Checks if a pawn move of the given color can go to this target field.
    /// Besides the regular targets, a pawn may move into a horse of the same color to form a rider.
    private func checkPawnTarget(at position: BoardPosition, color: PieceColor) -> Bool {
        checkTarget(at: position, color: color) || board.piece(at: position).type == .horse
    }

    private func checkTarget(at position: BoardPosition, color: PieceColor) -> Bool {
        guard !includeOwnPieces else { return true }
        return isEmpty(at: position) || matchesColor(color: color.opponent, at: position)
    }

    private func isEmpty(at position: BoardPosition) -> Bool {
        board.piece(at: position).type == .none
    }

    private func matchesColor(color: PieceColor, at position: BoardPosition) -> Bool {
        board.piece(at: position).color == color
    }
}
