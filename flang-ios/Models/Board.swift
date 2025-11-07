import Foundation

/// Board represents only the position of pieces on an 8x8 board
/// All game state (turn, history, etc.) belongs in Game
struct Board: Equatable {

    static let boardSize: Int = 8
    static let arraySize: Int = boardSize * boardSize

    typealias Index = Int

    private(set) var pieces: [Piece]
    
    var winner: PieceColor? {
        guard let whiteKing = findKingIndex(color: .white) else { return .black }
        guard let blackKing = findKingIndex(color: .black) else { return .white }
        return if Self.y(of: whiteKing) == Self.winningY(for: .white) {
            .white
        } else if Self.y(of: blackKing) == Self.winningY(for: .black) {
            .black
        } else {
            nil
        }
    }

    // MARK: - Initialization

    init(pieces: [Piece] = Array(repeating: .init(), count: Self.arraySize)) {
        assert(pieces.count == Self.arraySize)
        self.pieces = pieces
    }

    /// Setup default starting position
    static func defaultPosition() -> Board {
        var board = Board()
        // Row 0: "  PRHFUK" - White back rank
        try? board.set(.init(type: .pawn, color: .white), at: Self.index(x: 2, y: 0))
        try? board.set(.init(type: .rook, color: .white), at: Self.index(x: 3, y: 0))
        try? board.set(.init(type: .horse, color: .white), at: Self.index(x: 4, y: 0))
        try? board.set(.init(type: .flanger, color: .white), at: Self.index(x: 5, y: 0))
        try? board.set(.init(type: .uni, color: .white), at: Self.index(x: 6, y: 0))
        try? board.set(.init(type: .king, color: .white), at: Self.index(x: 7, y: 0))
        // Row 1: "  PPPPPP" - White pawns
        for x in 2..<8 {
            try? board.set(.init(type: .pawn, color: .white), at: Self.index(x: x, y: 1))
        }
        // Row 6: "pppppp  " - Black pawns
        for x in 0..<6 {
            try? board.set(.init(type: .pawn, color: .black), at: Self.index(x: x, y: 6))
        }
        // Row 7: "kufhrp  " - Black back rank
        try? board.set(.init(type: .king, color: .black), at: Self.index(x: 0, y: 7))
        try? board.set(.init(type: .uni, color: .black), at: Self.index(x: 1, y: 7))
        try? board.set(.init(type: .flanger, color: .black), at: Self.index(x: 2, y: 7))
        try? board.set(.init(type: .horse, color: .black), at: Self.index(x: 3, y: 7))
        try? board.set(.init(type: .rook, color: .black), at: Self.index(x: 4, y: 7))
        try? board.set(.init(type: .pawn, color: .black), at: Self.index(x: 5, y: 7))

        return board
    }

    // MARK: - Coordinate Helpers

    static func x(of index: Index) -> Int { index % boardSize }
    static func y(of index: Index) -> Int { index / boardSize }
    static func index(x: Int, y: Int) -> Index { y * boardSize + x }
    static func winningY(for color: PieceColor) -> Int {
        color == .white ? boardSize - 1 : 0
    }
    static func validate(_ index: Index) throws(Error) {
        guard index >= 0 && index < Self.arraySize else { throw .indexOutOfBounds }
    }

    /// Convert index to algebraic notation (e.g., 0 -> "A1", 63 -> "H8")
    static func notation(for index: Index) -> String {
        let file = String(UnicodeScalar(UInt8(65 + x(of: index))))  // A-H
        let rank = y(of: index) + 1  // 1-8
        return "\(file)\(rank)"
    }

    /// Parse algebraic notation to index (e.g., "A1" -> 0, "H8" -> 63)
    static func parseNotation(_ notation: String) -> Index? {
        guard notation.count == 2 else { return nil }
        let upper = notation.uppercased()
        guard let fileChar = upper.first,
              let rankChar = upper.last,
              let file = fileChar.asciiValue,
              let rank = rankChar.wholeNumberValue else {
            return nil
        }

        let x = Int(file) - 65  // 'A' = 65
        let y = rank - 1

        guard x >= 0, x < boardSize, y >= 0, y < boardSize else { return nil }
        return index(x: x, y: y)
    }

    // MARK: - Piece Access

    func piece(at index: Index) throws(Error) -> Piece {
        guard (try? Self.validate(index)) != nil else { throw .indexOutOfBounds }
        return pieces[index]
    }

    func piece(x: Int, y: Int) throws(Error) -> Piece {
        try piece(at: Self.index(x: x, y: y))
    }

    subscript(index: Index) -> Piece? {
        try? piece(at: index)
    }

    subscript(x: Int, y: Int) -> Piece? {
        try? piece(x: x, y: y)
    }

    // MARK: - Piece Modification

    private mutating func set(_ state: Piece, at index: Index) throws(Error) {
        try Self.validate(index)
        pieces[index] = state
    }
    
    private mutating func clear(at index: Index) {
        try? set(.init(), at: index)
    }
    
    /// Unfreeze the piece of the given color
    private mutating func unfreeze(_ color: PieceColor) {
        for index in 0...Self.arraySize {
            guard let piece = try? piece(at: index), piece.color == color && piece.frozen else { continue }
            pieces[index].frozen = false
        }
    }
    
    private mutating func freeze(at index: Index) throws(Error) {
        let piece = try piece(at: index)
        guard piece.type != .none else { throw .noPieceFound }
        guard piece.type != .king else { throw .kingCannotBeFrozen }
        pieces[index].frozen = true
    }
    
    /// - returns: The piece that was taken by the move if not none and whether the moved piece was promoted.
    /// - throws: Throws if the provided indices are out of bounds or the piece to move is of type `.none`
    /// - warning: This method does not check for move validity.
    @discardableResult
    mutating func move(from fromIndex: Index, to toIndex: Index) throws(Error) -> (takenPiece: Piece?, promoted: Bool) {
        var piece = try piece(at: fromIndex), takenPiece = try self.piece(at: toIndex)
        guard piece.type != .none else { throw .noPieceFound }
        guard !piece.frozen else { throw .pieceFrozen }
        clear(at: fromIndex)
        let promoted: Bool
        if piece.type == .pawn, Self.y(of: toIndex) == Self.winningY(for: piece.color) {
            piece.type = .uni
            try set(piece, at: toIndex)
            promoted = true
        } else {
            try set(piece, at: toIndex)
            promoted = false
        }
        unfreeze(piece.color)
        if piece.type != .king {
            try freeze(at: toIndex)
        }
        return (takenPiece.type != .none ? takenPiece : nil, promoted)
    }
    
    /// - throws: Throws if the provided indices are out of bounds, there is no piece to move back or the position to which the piece is
    /// supposed to be moved back to is already taken by another piece.
    /// - warning: This method does not check for move validity.
    mutating func revert(
        from fromIndex: Index,
        to toIndex: Index,
        freeze previouslyFrozenIndex: Index?,
        reinstate takenPiece: Piece?
    ) throws(Error) {
        let piece = try piece(at: toIndex)
        guard piece.type != .none else { throw .noPieceFound }
        guard try self.piece(at: fromIndex).type == .none else { throw .positionTaken }
        clear(at: toIndex)
        try set(piece, at: fromIndex)
        unfreeze(piece.color)
        if let previouslyFrozenIndex {
            try freeze(at: previouslyFrozenIndex)
        }
        if let takenPiece {
            try set(takenPiece, at: toIndex)
        }
    }

    // MARK: - Search

    private func findIndex(type: PieceType, color: PieceColor) -> Index? {
        for index in 0..<pieces.count where pieces[index].type == type && pieces[index].color == color {
            return index
        }
        return nil
    }

    private func findKingIndex(color: PieceColor) -> Index? {
        findIndex(type: .king, color: color)
    }
    
    func frozenPieceIndex(for pieceColor: PieceColor) -> Index? {
        for index in 0..<pieces.count where pieces[index].color == pieceColor && pieces[index].frozen {
            return index
        }
        return nil
    }
    
    enum Error: Swift.Error {
        case indexOutOfBounds
        case noPieceFound
        case pieceFrozen
        case positionTaken
        case kingCannotBeFrozen
    }
}
