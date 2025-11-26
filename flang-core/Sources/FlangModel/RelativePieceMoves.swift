enum RelativePieceMoves {
    
    static let kingMoves: [[Vector]] = [[(-1, -1)], [(-1, 0)], [(-1, 1)], [(0, -1)], [(0, 1)], [(1, -1)], [(1, 0)], [(1, 1)]]
    static let whitePawnMoves: [[Vector]] = [[(-1, 1)], [(0, 1)], [(1, 1)]]
    static let blackPawnMoves: [[Vector]] = [[(-1, -1)], [(0, -1)], [(1, -1)]]
    static let horseMoves: [[Vector]] = [[(-1, 2)], [(-1, -2)], [(-2, 1)], [(-2, -1)], [(1, 2)], [(1, -2)], [(2, -1)], [(2, 1)]]
    static let rookMoves: [[Vector]] = [
        [(0, 1), (0, 2), (0, 3), (0, 4), (0, 5), (0, 6), (0, 7)],
        [(0, -1), (0, -2), (0, -3), (0, -4), (0, -5), (0, -6), (0, -7)],
        [(1, 0), (2, 0), (3, 0), (4, 0), (5, 0), (6, 0), (7, 0)],
        [(-1, 0), (-2, 0), (-3, 0), (-4, 0), (-5, 0), (-6, 0), (-7, 0)]
    ]
    static let uniMoves: [[Vector]] = rookMoves + horseMoves + [
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

    static func getMoveSequences(for type: PieceType, and color: PieceColor) -> [[Vector]] {
        switch type {
        case .pawn: color == .white ? whitePawnMoves : blackPawnMoves
        case .horse: horseMoves
        case .rook: rookMoves
        case .flanger: flangerMoves
        case .uni: uniMoves
        case .king: kingMoves
        default: []
        }
    }

    static func hasDoubleMoves(type: PieceType) -> Bool {
        return type == .flanger
    }
}
