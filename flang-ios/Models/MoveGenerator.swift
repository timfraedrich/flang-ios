import Foundation

class MoveGenerator {
    
    var board: Board
    let includeOwnPieces: Bool
    let kingRange: Int
    let ignoreFreeze: Bool

    init(board: Board, includeOwnPieces: Bool = false, kingRange: Int = 1, ignoreFreeze: Bool = false) {
        self.board = board
        self.includeOwnPieces = includeOwnPieces
        self.kingRange = kingRange
        self.ignoreFreeze = ignoreFreeze
    }

    // MARK: - Public API

    /// Generate all legal moves for a color
    func generateMoves(for color: PieceColor) -> [Action] {
        var moves: [Action] = []
        for index in 0..<Board.arraySize {
            guard let piece = board[index], piece.type != .none, piece.color == color else { continue }
            let pieceMoves = generateMovesForPiece(at: index, state: piece)
            moves.append(contentsOf: pieceMoves)
        }
        return moves
    }

    /// Generate moves for a specific piece at an index
    func generateMovesForPiece(at fromIndex: Board.Index, state: Piece) -> [Action] {
        var moves: [Action] = []

        // Can't move frozen pieces (unless ignoring freeze)
        if !ignoreFreeze && state.frozen {
            return moves
        }

        let color = state.color
        let targetIndices = generateTargetIndices(from: fromIndex, state: state)

        for toIndex in targetIndices where checkTarget(for: toIndex, color: color) {
            moves.append(.move(from: fromIndex, to: toIndex))
        }

        return moves
    }

    /// Check if a specific action is legal
    func isLegalMove(_ action: Action, for color: PieceColor) -> Bool {
        switch action {
        case .move(let from, let to):
            // Check if piece exists and is the right color
            guard let piece = board[from], piece.type != .none, piece.color == color else { return false }
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
    func legalTargets(for index: Board.Index) -> [Board.Index] {
        guard let piece = board[index], piece.type != .none else { return [] }
        let moves = generateMovesForPiece(at: index, state: piece)
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
    private func generateTargetIndices(from index: Board.Index, state: Piece) -> [Board.Index] {
        let type = state.type
        let color = state.color
        return switch type {
        case .pawn: generatePawnTargets(from: index, color: color)
        case .king: generateKingTargets(from: index, color: color)
        default: generateStandardTargets(from: index, state: state)
        }
    }

    /// Pawn move generation (optimized)
    private func generatePawnTargets(from index: Board.Index, color: PieceColor) -> [Board.Index] {
        var targets: [Int] = []
        let yDirection = color == .white ? 1 : -1 // white moves up, black moves down
        let x = Board.x(of: index)
        let y = Board.y(of: index)
        // Forward
        if checkTarget(x: x, y: y + yDirection, color: color) {
            targets.append(Board.index(x: x, y: y + yDirection))
        }
        // Diagonal left
        if checkTarget(x: x - 1, y: y + yDirection, color: color) {
            targets.append(Board.index(x: x - 1, y: y + yDirection))
        }
        // Diagonal right
        if checkTarget(x: x + 1, y: y + yDirection, color: color) {
            targets.append(Board.index(x: x + 1, y: y + yDirection))
        }

        return targets
    }

    /// King move generation (optimized)
    private func generateKingTargets(from index: Board.Index, color: PieceColor) -> [Int] {
        var targets: [Int] = []
        let x = Board.x(of: index)
        let y = Board.y(of: index)
        for dx in -kingRange...kingRange {
            for dy in -kingRange...kingRange {
                if dx == 0 && dy == 0 { continue }
                if checkTarget(x: x + dx, y: y + dy, color: color) {
                    targets.append(Board.index(x: x + dx, y: y + dy))
                }
            }
        }
        return targets
    }

    /// Standard piece move generation (rook, horse, flanger, uni)
    private func generateStandardTargets(from index: Board.Index, state: Piece) -> [Int] {
        var targets: [Board.Index] = []
        let type = state.type
        let color = state.color
        let moveSequences = RelativePieceMoves.getMoves(for: type)
        let hasDouble = RelativePieceMoves.hasDoubleMoves(type: type)

        var seenTargets: Set<Board.Index> = []

        for moveSequence in moveSequences {
            // Try to move along this particular sequence
            for vector in moveSequence {
                let x = Board.x(of: index) + vector.x
                let y = Board.y(of: index) + vector.y
                // If target is invalid, stop this sequence (but continue with others)
                if !checkTarget(x: x, y: y, color: color) {
                    break
                }
                let targetIndex = Board.index(x: x, y: y)
                // For flanger with double moves, avoid duplicates
                if hasDouble {
                    if !seenTargets.contains(targetIndex) {
                        seenTargets.insert(targetIndex)
                        targets.append(targetIndex)
                    }
                } else {
                    targets.append(targetIndex)
                }
                // Stop this sequence if we hit a piece (but continue with other sequences)
                if !isEmpty(x: x, y: y) {
                    break
                }
            }
        }
        return targets
    }

    private func checkTarget(for index: Board.Index, color: PieceColor) -> Bool {
        checkTarget(x: Board.x(of: index), y: Board.y(of: index), color: color)
    }

    /// Check if target is valid for color
    private func checkTarget(x: Int, y: Int, color: PieceColor) -> Bool {
        guard isValid(x: x, y: y) else { return false }
        if includeOwnPieces {
            return true
        }
        // Can move to empty square or capture opponent piece
        return isEmpty(x: x, y: y) || matchesColor(color: color.opponent, x: x, y: y)
    }

    private func isEmpty(x: Int, y: Int) -> Bool {
        !(board[x, y]?.type != PieceType.none)
    }

    private func matchesColor(color: PieceColor, x: Int, y: Int) -> Bool {
        board[x, y]?.color == color
    }

    private func isValid(x: Int, y: Int) -> Bool {
        x >= 0 && y >= 0 && x < Board.boardSize && y < Board.boardSize
    }
}
