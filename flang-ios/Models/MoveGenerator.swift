import Foundation

typealias Vector = (x: Int, y: Int)

// Define move patterns for each piece type
struct PieceMoves {
    static let kingMoves: [[Vector]] = [
        [(-1, -1)],
        [(-1, 0)],
        [(-1, 1)],
        [(0, -1)],
        [(0, 1)],
        [(1, -1)],
        [(1, 0)],
        [(1, 1)]
    ]

    static let pawnMoves: [[Vector]] = [
        [(-1, 1)],
        [(0, 1)],
        [(1, 1)]
    ]

    static let horseMoves: [[Vector]] = [
        [(-1, 2)],
        [(-1, -2)],
        [(-2, 1)],
        [(-2, -1)],
        [(1, 2)],
        [(1, -2)],
        [(2, -1)],
        [(2, 1)]
    ]

    static let rookMoves: [[Vector]] = [
        [(0, 1), (0, 2), (0, 3), (0, 4), (0, 5), (0, 6), (0, 7)],
        [(0, -1), (0, -2), (0, -3), (0, -4), (0, -5), (0, -6), (0, -7)],
        [(1, 0), (2, 0), (3, 0), (4, 0), (5, 0), (6, 0), (7, 0)],
        [(-1, 0), (-2, 0), (-3, 0), (-4, 0), (-5, 0), (-6, 0), (-7, 0)]
    ]

    static let uniMoves: [[Vector]] = [
        // Rook moves (straight lines)
        [(0, 1), (0, 2), (0, 3), (0, 4), (0, 5), (0, 6), (0, 7)],
        [(0, -1), (0, -2), (0, -3), (0, -4), (0, -5), (0, -6), (0, -7)],
        [(1, 0), (2, 0), (3, 0), (4, 0), (5, 0), (6, 0), (7, 0)],
        [(-1, 0), (-2, 0), (-3, 0), (-4, 0), (-5, 0), (-6, 0), (-7, 0)],
        // Knight moves
        [(-1, 2)],
        [(-1, -2)],
        [(-2, 1)],
        [(-2, -1)],
        [(1, 2)],
        [(1, -2)],
        [(2, -1)],
        [(2, 1)],
        // Diagonal moves
        [(-1, -1), (-2, -2), (-3, -3), (-4, -4), (-5, -5), (-6, -6), (-7, -7)],
        [(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7)],
        [(1, -1), (2, -2), (3, -3), (4, -4), (5, -5), (6, -6), (7, -7)],
        [(-1, 1), (-2, 2), (-3, 3), (-4, 4), (-5, 5), (-6, 6), (-7, 7)]
    ]

    static let flangerMoves: [[Vector]] = [
        [(-1, 1), (-2, 0), (-3, 1), (-4, 0), (-5, 1), (-6, 0), (-7, 1)],
        [(-1, -1), (-2, 0), (-3, -1), (-4, 0), (-5, -1), (-6, 0), (-7, -1)],
        [(1, 1), (2, 0), (3, 1), (4, 0), (5, 1), (6, 0), (7, 1)],
        [(1, -1), (2, 0), (3, -1), (4, 0), (5, -1), (6, 0), (7, -1)],
        [(1, -1), (0, -2), (1, -3), (0, -4), (1, -5), (0, -6), (1, -7)],
        [(-1, -1), (0, -2), (-1, -3), (0, -4), (-1, -5), (0, -6), (-1, -7)],
        [(1, 1), (0, 2), (1, 3), (0, 4), (1, 5), (0, 6), (1, 7)],
        [(-1, 1), (0, 2), (-1, 3), (0, 4), (-1, 5), (0, 6), (-1, 7)]
    ]

    static func getMoves(for type: PieceType) -> [[Vector]] {
        switch type {
        case .pawn: return pawnMoves
        case .horse: return horseMoves
        case .rook: return rookMoves
        case .flanger: return flangerMoves
        case .uni: return uniMoves
        case .king: return kingMoves
        default: return []
        }
    }

    static func hasDoubleMoves(type: PieceType) -> Bool {
        return type == .flanger
    }
}

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

    // Generate all legal moves for a color
    func generateMoves(for color: PieceColor) -> [Move] {
        var moves: [Move] = []

        guard !board.gameIsComplete() else { return moves }

        for index in 0..<Board.arraySize {
            let piece = board.get(at: index)
            let pieceType = piece.type
            guard pieceType != .none else { continue }
            guard piece.color == color else { continue }
            let pieceMoves = generateMovesForPiece(at: index, state: piece)
            moves.append(contentsOf: pieceMoves)
        }

        return moves
    }

    // Generate moves for a specific piece
    func generateMovesForPiece(at fromIndex: Board.Index, state: PieceState) -> [Move] {
        var moves: [Move] = []

        // Can't move frozen pieces (unless ignoring freeze)
        if !ignoreFreeze && state.frozen {
            return moves
        }

        let color = state.color
        let targetIndices = generateTargetIndices(from: fromIndex, state: state)

        for toIndex in targetIndices where checkTarget(for: toIndex, color: color) {
            let move = Move(
                from: fromIndex,
                to: toIndex,
                fromPieceState: state,
                toPieceState: board.get(at: toIndex),
                previouslyFrozenPieceIndex: board.frozenPieceIndex(for: color)
            )
            moves.append(move)
        }

        return moves
    }

    // Generate target indices for a piece
    private func generateTargetIndices(from index: Board.Index, state: PieceState) -> [Board.Index] {
        let type = state.type
        let color = state.color
        return switch type {
        case .pawn: generatePawnTargets(from: index, color: color)
        case .king: generateKingTargets(from: index, color: color)
        default: generateStandardTargets(from: index, state: state)
        }
    }

    // Pawn move generation (optimized)
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

    // King move generation (optimized)
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

    // Standard piece move generation (rook, horse, flanger, uni)
    private func generateStandardTargets(from index: Board.Index, state: PieceState) -> [Int] {
        var targets: [Board.Index] = []
        let type = state.type
        let color = state.color
        let moveSequences = PieceMoves.getMoves(for: type)
        let hasDouble = PieceMoves.hasDoubleMoves(type: type)

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

    // Check if target is valid for color
    private func checkTarget(x: Int, y: Int, color: PieceColor) -> Bool {
        guard isValid(x: x, y: y) else { return false }
        if includeOwnPieces {
            return true
        }
        // Can move to empty square or capture opponent piece
        return isEmpty(x: x, y: y) || matchesColor(color: color.opponent, x: x, y: y)
    }

    private func isEmpty(x: Int, y: Int) -> Bool {
        board.get(x: x, y: y).type == .none
    }

    private func matchesColor(color: PieceColor, x: Int, y: Int) -> Bool {
        board.get(x: x, y: y).color == color
    }

    private func isValid(x: Int, y: Int) -> Bool {
        x >= 0 && y >= 0 && x < Board.boardSize && y < Board.boardSize
    }
}
