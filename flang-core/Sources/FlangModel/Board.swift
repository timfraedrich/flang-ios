import Foundation

/// Board represents only the position of pieces on an 8x8 board
/// All game state (turn, history, etc.) belongs in Game
public struct Board: Hashable, Sendable {
    
    typealias Index = Int

    public static let boardSize: Int = 8
    public static let arraySize: Int = boardSize * boardSize
    public static var positions: [BoardPosition] { (0..<Board.arraySize).compactMap(BoardPosition.init(index:)) }
    public static var rows: [[BoardPosition]] {
        (0..<Board.boardSize).map { row in
            (0..<Board.boardSize).compactMap { col in
                .init(row: row, col: col)
            }
        }
    }
    
    public private(set) var pieces: [Piece]

    // MARK: - Initialization

    public init(pieces: [Piece] = Array(repeating: .init(), count: Self.arraySize)) {
        assert(pieces.count == Self.arraySize)
        self.pieces = pieces
    }

    /// Setup default starting position
    public static func defaultPosition() -> Board {
        var board = Board()
        // Row 0: "  PRHFUK" - White back rank
        try? board.set(.init(type: .pawn, color: .white), at: Self.index(col: 2, row: 0))
        try? board.set(.init(type: .rook, color: .white), at: Self.index(col: 3, row: 0))
        try? board.set(.init(type: .horse, color: .white), at: Self.index(col: 4, row: 0))
        try? board.set(.init(type: .flanger, color: .white), at: Self.index(col: 5, row: 0))
        try? board.set(.init(type: .uni, color: .white), at: Self.index(col: 6, row: 0))
        try? board.set(.init(type: .king, color: .white), at: Self.index(col: 7, row: 0))
        // Row 1: "  PPPPPP" - White pawns
        for x in 2..<8 {
            try? board.set(.init(type: .pawn, color: .white), at: Self.index(col: x, row: 1))
        }
        // Row 6: "pppppp  " - Black pawns
        for x in 0..<6 {
            try? board.set(.init(type: .pawn, color: .black), at: Self.index(col: x, row: 6))
        }
        // Row 7: "kufhrp  " - Black back rank
        try? board.set(.init(type: .king, color: .black), at: Self.index(col: 0, row: 7))
        try? board.set(.init(type: .uni, color: .black), at: Self.index(col: 1, row: 7))
        try? board.set(.init(type: .flanger, color: .black), at: Self.index(col: 2, row: 7))
        try? board.set(.init(type: .horse, color: .black), at: Self.index(col: 3, row: 7))
        try? board.set(.init(type: .rook, color: .black), at: Self.index(col: 4, row: 7))
        try? board.set(.init(type: .pawn, color: .black), at: Self.index(col: 5, row: 7))

        return board
    }

    /// Initialize board from FBN (Flang Board Notation) piece string
    /// - Parameter fbnPieces: FBN string WITHOUT the leading color character (+/-)
    /// - Note: This is a helper for Game to use. Game handles the color prefix.
    public init?(fromFBNPieces fbnPieces: String) {
        self.init()

        var currentIndex = 0
        var lastPieceIndex: Int?
        var numberBuffer = ""

        for char in fbnPieces {
            if currentIndex >= Self.arraySize && !char.isNumber {
                return nil // Too many pieces
            }

            if char.isNumber {
                // Accumulate digits for multi-digit numbers
                numberBuffer.append(char)
            } else {
                // Flush any accumulated number
                if !numberBuffer.isEmpty {
                    guard let skipCount = Int(numberBuffer) else { return nil }
                    currentIndex += skipCount
                    numberBuffer = ""
                }

                if currentIndex >= Self.arraySize {
                    return nil // Too many pieces
                }

                if char == "-" {
                    // Minus: freeze the last placed piece
                    guard let index = lastPieceIndex else { return nil }
                    pieces[index].frozen = true
                } else if char.isLetter {
                    // Letter: place piece at current location
                    guard let (type, color) = PieceType.from(character: char) else { return nil }
                    guard type != .none else { return nil } // Empty squares should use numbers
                    pieces[currentIndex] = Piece(type: type, color: color, frozen: false)
                    lastPieceIndex = currentIndex
                    currentIndex += 1
                } else {
                    return nil // Invalid character
                }
            }
        }

        // Flush any remaining number at the end
        if !numberBuffer.isEmpty {
            guard let skipCount = Int(numberBuffer) else { return nil }
            currentIndex += skipCount
        }
    }

    // MARK: - Coordinate Helpers

    private static func col(of index: Index) -> Int { index % boardSize }
    private static func row(of index: Index) -> Int { index / boardSize }
    private static func index(col: Int, row: Int) -> Index { row * boardSize + col }
    
    static func opponentsBaseRow(for color: PieceColor) -> Int {
        color == .white ? boardSize - 1 : 0
    }
    
    static func validate(_ index: Index) throws(Error) {
        guard index >= 0 && index < Self.arraySize else { throw .indexOutOfBounds }
    }

    // MARK: - Piece Access

    public func piece(at position: BoardPosition) -> Piece {
        pieces[position.index]
    }

    public subscript(position: BoardPosition) -> Piece {
        piece(at: position)
    }
    
    private func piece(at index: Index) throws(Error) -> Piece {
        guard (try? Self.validate(index)) != nil else { throw .indexOutOfBounds }
        return pieces[index]
    }

    // MARK: - Piece Modification

    private mutating func set(_ state: Piece, at index: Index) throws(Error) {
        try Self.validate(index)
        pieces[index] = state
    }
    
    private mutating func clear(at index: Index) {
        try? set(.init(), at: index)
    }
    
    public mutating func promotePawn(at position: BoardPosition) throws(Error) {
        var piece = try piece(at: position.index)
        guard piece.type != .none else { throw .noPieceFound }
        guard piece.type == .pawn else { throw .onlyPawnsCanBePromoted }
        piece.type = .uni
        try set(piece, at: position.index)
    }
    
    public mutating func demoteUni(at position: BoardPosition) throws(Error) {
        var piece = try piece(at: position.index)
        guard piece.type != .none else { throw .noPieceFound }
        guard piece.type == .uni else { throw .onlyUnisCanBeDemoted }
        piece.type = .pawn
        try set(piece, at: position.index)
    }
    
    /// Unfreeze all pieces of the given color.
    /// - returns: The first unfrozen position.
    @discardableResult
    public mutating func unfreeze(_ color: PieceColor) -> BoardPosition? {
        var firstUnfrozenPosition: BoardPosition?
        for index in 0...Self.arraySize {
            guard let piece = try? piece(at: index), piece.color == color && piece.frozen else { continue }
            pieces[index].frozen = false
            guard firstUnfrozenPosition == nil else { continue }
            firstUnfrozenPosition = .init(index: index)
        }
        return firstUnfrozenPosition
    }
    
    /// Freezes the piece at the specified position.
    public mutating func freeze(at position: BoardPosition) throws(Error) {
        let piece = try piece(at: position.index)
        guard piece.type != .none else { throw .noPieceFound }
        guard piece.type != .king else { throw .kingCannotBeFrozen }
        pieces[position.index].frozen = true
    }
    
    /// - returns: The piece that was taken by the move if not none.
    /// - throws: Throws if the provided indices are out of bounds or the piece to move is of type `.none`
    /// - warning: This method does not check for move validity.
    @discardableResult
    public mutating func move(
        from fromPosition: BoardPosition,
        to toPosition: BoardPosition
    ) throws(Error) -> Piece? {
        let fromIndex = fromPosition.index, toIndex = toPosition.index
        let piece = try piece(at: fromIndex), takenPiece = try self.piece(at: toIndex)
        guard piece.type != .none else { throw .noPieceFound }
        guard !piece.frozen else { throw .pieceFrozen }
        clear(at: fromIndex)
        try set(piece, at: toIndex)
        return takenPiece
    }
    
    /// - throws: Throws if the provided indices are out of bounds, there is no piece to move back or the position to which the piece is
    /// supposed to be moved back to is already taken by another piece.
    /// - warning: This method does not check for move validity.
    public mutating func revert(
        from fromPosition: BoardPosition,
        to toPosition: BoardPosition,
        reinstate takenPiece: Piece?
    ) throws(Error) {
        let toIndex = toPosition.index, fromIndex = fromPosition.index
        let piece = try piece(at: toIndex)
        guard piece.type != .none else { throw .noPieceFound }
        guard try self.piece(at: fromIndex).type == .none else { throw .positionTaken }
        clear(at: toIndex)
        try set(piece, at: fromIndex)
        if let takenPiece {
            try set(takenPiece, at: toIndex)
        }
    }

    // MARK: - Search

    public func findPiece(of type: PieceType, and color: PieceColor) -> BoardPosition? {
        for index in 0..<pieces.count where pieces[index].type == type && pieces[index].color == color {
            return .init(index: index)
        }
        return nil
    }
    
    public func frozenBoardPosition(for pieceColor: PieceColor) -> BoardPosition? {
        for index in 0..<pieces.count where pieces[index].color == pieceColor && pieces[index].frozen {
            return BoardPosition(index: index)
        }
        return nil
    }
    
    public enum Error: Swift.Error {
        case indexOutOfBounds
        case noPieceFound
        case pieceFrozen
        case positionTaken
        case kingCannotBeFrozen
        case onlyPawnsCanBePromoted
        case onlyUnisCanBeDemoted
    }
}
