import Foundation

/// Represents any action that can be performed in a game
enum Action: Equatable, Hashable {
    
    case move(from: Board.Index, to: Board.Index)
    case resign(color: PieceColor)

    // MARK: - Notation

    /// Get full notation for this action
    /// - Parameter board: The board state before the action
    func notation(on board: Board) throws -> String {
        switch self {
        case .move(let from, let to):
            let piece = try board.piece(at: from)
            let target = try board.piece(at: to)
            let pieceChar = piece.type.character(for: piece.color)
            let fromNotation = Board.notation(for: from)
            let toNotation = Board.notation(for: to)
            let separator = target.type != .none ? "x" : "-"
            return "\(pieceChar)\(fromNotation)\(separator)\(toNotation)"

        case .resign(let color):
            return "#\(color == .white ? "+" : "-")"
        }
    }

    /// Get FMNv2 short notation for this action
    /// - Parameters:
    ///   - board: The board state before the action
    ///   - atMove: The color to move
    ///   - moveGenerator: Optional move generator (created if not provided)
    func shortNotation(on board: Board, atMove: PieceColor, moveGenerator: MoveGenerator? = nil) throws -> String {
        switch self {
        case .move(let from, let to):
            let piece = try board.piece(at: from)
            let toNotation = Board.notation(for: to).lowercased()
            let fromNotation = Board.notation(for: from).lowercased()

            let generator = moveGenerator ?? MoveGenerator(board: board)
            let allMoves = generator.generateMoves(for: atMove)

            // Find all moves to this target
            let movesToTarget = allMoves.filter { action in
                if case .move(_, let actionTo) = action {
                    return actionTo == to
                }
                return false
            }

            // If only one move can reach this target, use just target notation
            if movesToTarget.count == 1 {
                return toNotation
            }

            // Find moves with the same piece type
            let samePieceTypeMoves = try movesToTarget.filter { action in
                if case .move(let actionFrom, _) = action {
                    let actionPiece = try board.piece(at: actionFrom)
                    return actionPiece.type == piece.type
                }
                return false
            }

            // If only one piece of this type can reach target, use piece + target
            if samePieceTypeMoves.count == 1 {
                let pieceChar = piece.type.character(for: piece.color)
                return "\(pieceChar)\(toNotation)"
            }

            // Otherwise use from + to
            return "\(fromNotation)\(toNotation)"

        case .resign:
            return try notation(on: board)
        }
    }

    // MARK: - Parsing

    /// Parse an action from FMN notation string (supports both v1 and v2)
    /// - Parameters:
    ///   - notation: The notation string
    ///   - board: The current board state
    ///   - atMove: The color to move
    ///   - moveGenerator: Optional move generator (created if not provided)
    static func parse(_ notation: String, on board: Board, atMove: PieceColor, moveGenerator: MoveGenerator? = nil) -> Action? {
        // Handle resignation
        if notation.starts(with: "#") {
            guard notation.count == 2 else { return nil }
            let colorChar = notation.last!
            switch colorChar {
            case "+": return .resign(color: .white)
            case "-": return .resign(color: .black)
            default: return nil
            }
        }

        let clean = notation.replacingOccurrences(of: "-", with: "")
                           .replacingOccurrences(of: "x", with: "")
                           .replacingOccurrences(of: " ", with: "")

        let generator = moveGenerator ?? MoveGenerator(board: board)

        switch clean.count {
        case 2:
            // FMNv2: "b2" - find the only move to this target
            return parseFMNv2Length2(clean, board: board, atMove: atMove, generator: generator)

        case 3:
            // FMNv2: "Uf3" or "pb2" - piece type + target
            return parseFMNv2Length3(clean, board: board, atMove: atMove, generator: generator)

        case 4:
            // FMNv2: "g2h3" - from + to (no piece type)
            return parseFMNv2Length4(clean)

        case 5:
            // FMNv1 without dash: "PG2H3" - piece + from + to
            return parseFMNv1Length5(clean)

        default:
            return nil
        }
    }

    /// Parse FMNv2 length 2: "b2" - find only legal move to target
    private static func parseFMNv2Length2(_ notation: String, board: Board, atMove: PieceColor, generator: MoveGenerator) -> Action? {
        guard let targetIndex = Board.parseNotation(notation) else { return nil }

        // Find all legal moves to this target
        let allMoves = generator.generateMoves(for: atMove)
        let movesToTarget = allMoves.filter { action in
            if case .move(_, let to) = action {
                return to == targetIndex
            }
            return false
        }

        // Must be exactly one legal move to this target
        guard movesToTarget.count == 1 else { return nil }
        return movesToTarget.first
    }

    /// Parse FMNv2 length 3: "Uf3" or "pb2" - piece type + target
    private static func parseFMNv2Length3(_ notation: String, board: Board, atMove: PieceColor, generator: MoveGenerator) -> Action? {
        let pieceChar = notation.first!
        let targetNotation = String(notation.dropFirst())
        guard let targetIndex = Board.parseNotation(targetNotation) else { return nil }

        // Determine the piece type from the character
        guard let (pieceType, _) = PieceType.from(character: pieceChar) else { return nil }

        // Find all legal moves to this target with this piece type
        let allMoves = generator.generateMoves(for: atMove)
        let matchingMoves = allMoves.filter { action in
            guard case .move(let from, let to) = action, let piece = board[from] else { return false }
            return to == targetIndex && piece.type == pieceType
        }

        // Must be exactly one legal move matching these criteria
        guard matchingMoves.count == 1 else { return nil }
        return matchingMoves.first
    }

    /// Parse FMNv2 length 4: "g2h3" - from + to
    private static func parseFMNv2Length4(_ notation: String) -> Action? {
        let fromNotation = String(notation.prefix(2))
        let toNotation = String(notation.suffix(2))
        guard let from = Board.parseNotation(fromNotation),
              let to = Board.parseNotation(toNotation) else {
            return nil
        }
        return .move(from: from, to: to)
    }

    /// Parse FMNv1 (length 5): "PG2H3" - piece + from + to
    /// This is FMNv1 after removing dashes: "PG2-H3" -> "PG2H3"
    private static func parseFMNv1Length5(_ notation: String) -> Action? {
        guard notation.count == 5 else { return nil }

        // Format: [Piece:1][From:2][To:2]
        // Example: PG2H3 = Piece P, From G2, To H3
        _ = notation[notation.startIndex]
        let fromStart = notation.index(notation.startIndex, offsetBy: 1)
        let fromEnd = notation.index(notation.startIndex, offsetBy: 3)
        let toStart = notation.index(notation.startIndex, offsetBy: 3)

        let fromNotation = String(notation[fromStart..<fromEnd])
        let toNotation = String(notation[toStart...])

        guard let from = Board.parseNotation(fromNotation),
              let to = Board.parseNotation(toNotation) else {
            return nil
        }

        // We have the piece character, but we don't need to validate it
        // since the move is fully specified by from and to
        return .move(from: from, to: to)
    }
}

// MARK: - CustomStringConvertible

extension Action: CustomStringConvertible {
    var description: String {
        switch self {
        case .move(let from, let to):
            return "\(Board.notation(for: from))\(Board.notation(for: to))"
        case .resign(let color):
            return "#\(color == .white ? "+" : "-")"
        }
    }
}
