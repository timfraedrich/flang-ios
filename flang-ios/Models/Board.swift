import Foundation

struct PieceState {
    
    static let TYPE_MASK: UInt8 = 0b11100000      // bits 5-7
    static let COLOR_MASK: UInt8 = 0b00010000     // bit 4
    static let FROZEN_MASK: UInt8 = 0b00001000    // bit 3
    
    static let TYPE_SHIFT = 5
    static let COLOR_SHIFT = 4
    static let FROZEN_SHIFT = 3
    
    private let rawValue: UInt8
    
    init() {
        rawValue = .zero
    }
    
    init(type: PieceType, color: PieceColor, frozen: Bool) {
        var rawValue: UInt8 = 0
        // Set type (3 bits, shifted to positions 5-7)
        rawValue = rawValue | ((type.rawValue & 0b111) << Self.TYPE_SHIFT)
        // Set color (1 bit, shifted to position 4)
        rawValue = rawValue | ((color.rawValue ? 0b1 : 0b0) << Self.COLOR_SHIFT)
        // Set frozen (1 bit, shifted to position 3)
        rawValue = rawValue | ((frozen ? 0b1 : 0b0) << Self.FROZEN_SHIFT)
        self.rawValue = rawValue
    }
    
    var type: PieceType {
        PieceType(rawValue: ((rawValue & Self.TYPE_MASK) >> Self.TYPE_SHIFT) & 0xFF)
    }
    
    var color: PieceColor {
        if (rawValue & Self.COLOR_MASK) != 0 { .white } else { .black }
    }
    
    var frozen: Bool {
        rawValue & Self.FROZEN_MASK != 0
    }
}

// Main Board class
struct Board {
    
    static let boardSize: Int = 8
    static let arraySize: Int = boardSize * boardSize
    
    static func x(of index: Index) -> Int { index % Self.boardSize }
    static func y(of index: Index) -> Int {  index / Self.boardSize }
    static func index(x: Int, y: Int) -> Index { y * Self.boardSize + x }
    static func winningY(for color: PieceColor) -> Int {
        switch color {
        case .white: boardSize - 1
        case .black: 0
        }
    }
    
    typealias Index = Int
    
    var pieces: [PieceState]
    var atMove: PieceColor
    var frozenWhiteIndex: Index?
    var frozenBlackIndex: Index?
    var moveNumber: UInt

    init() {
        self.pieces = Array(repeating: PieceState(), count: Self.arraySize)
        self.atMove = .white
        self.frozenWhiteIndex = nil
        self.frozenBlackIndex = nil
        self.moveNumber = 0
    }

    init(pieces: [PieceState], atMove: PieceColor, frozenWhiteIndex: Index?, frozenBlackIndex: Index?, moveNumber: UInt) {
        self.pieces = pieces
        self.atMove = atMove
        self.frozenWhiteIndex = frozenWhiteIndex
        self.frozenBlackIndex = frozenBlackIndex
        self.moveNumber = moveNumber
    }

    // Setup default starting position
    mutating func setupDefaultPosition() {
        pieces = Array(repeating: .init(), count: Self.arraySize)
        // Row 0: "  PRHFUK" - White back rank
        set(.init(type: .pawn, color: .white, frozen: false), at: Self.index(x: 2, y: 0))
        set(.init(type: .rook, color: .white, frozen: false), at: Self.index(x: 3, y: 0))
        set(.init(type: .horse, color: .white, frozen: false), at: Self.index(x: 4, y: 0))
        set(.init(type: .flanger, color: .white, frozen: false), at: Self.index(x: 5, y: 0))
        set(.init(type: .uni, color: .white, frozen: false), at: Self.index(x: 6, y: 0))
        set(.init(type: .king, color: .white, frozen: false), at: Self.index(x: 7, y: 0))
        // Row 1: "  PPPPPP" - White pawns
        for x in 2..<8 {
            set(.init(type: .pawn, color: .white, frozen: false), at: Self.index(x: x, y: 1))
        }
        // Row 6: "pppppp  " - Black pawns
        for x in 0..<6 {
            set(.init(type: .pawn, color: .black, frozen: false), at: Self.index(x: x, y: 6))
        }
        // Row 7: "kufhrp  " - Black back rank
        set(.init(type: .king, color: .black, frozen: false), at: Self.index(x: 0, y: 7))
        set(.init(type: .uni, color: .black, frozen: false), at: Self.index(x: 1, y: 7))
        set(.init(type: .flanger, color: .black, frozen: false), at: Self.index(x: 2, y: 7))
        set(.init(type: .horse, color: .black, frozen: false), at: Self.index(x: 3, y: 7))
        set(.init(type: .rook, color: .black, frozen: false), at: Self.index(x: 4, y: 7))
        set(.init(type: .pawn, color: .black, frozen: false), at: Self.index(x: 5, y: 7))

        atMove = PieceColor.white
        frozenWhiteIndex = nil
        frozenBlackIndex = nil
        moveNumber = 0
    }
    
    func get(at index: Index) -> PieceState {
        guard index >= 0 && index < Self.arraySize else { return .init() }
        return pieces[index]
    }
    
    func get(x: Int, y: Index) -> PieceState {
        get(at: Self.index(x: x, y: y))
    }

    // Set piece at index
    mutating func set(_ state: PieceState, at index: Int) {
        guard index >= 0 && index < Self.arraySize else { return }
        pieces[index] = state
        // Handle frozen piece tracking
        if index == frozenWhiteIndex {
            let stillFrozen = state.color.rawValue && state.frozen
            if !stillFrozen { frozenWhiteIndex = -1 }
        } else if index == frozenBlackIndex {
            let stillFrozen = !state.color.rawValue && state.frozen
            if !stillFrozen { frozenBlackIndex = -1 }
        }
        if state.frozen {
            freezePiece(for: state.color, at: index)
        }
    }

    // Clear piece at index
    mutating func clear(at index: Int) {
        set(.init(), at: index)
    }

    // Update piece at index with type and color
    mutating func update(at index: Int, type: PieceType, color: PieceColor) {
        if type != .none {
            // Pawn promotion to Uni at winning rank
            let writtenType = (type == .pawn && Self.y(of: index) == Self.winningY(for: color)) ? .uni : type
            let frozen = writtenType != .king
            set(.init(type: writtenType, color: color, frozen: frozen), at: index)
        } else {
            clear(at: index)
        }
    }

    // Get frozen piece index for color
    func frozenPieceIndex(for color: PieceColor) -> Index? {
        color == .white ? frozenWhiteIndex : frozenBlackIndex
    }

    // Set frozen piece index for color
    mutating func freezePiece(for color: PieceColor, at index: Index) {
        if color == .white {
            frozenWhiteIndex = index
        } else {
            frozenBlackIndex = index
        }
    }

    // Unfreeze pieces of given color
    mutating func unfreeze(for color: PieceColor) {
        guard let index = frozenPieceIndex(for: color) else { return }
        let currentPiece = get(at: index)
        set(.init(type: currentPiece.type, color: currentPiece.color, frozen: false), at: index)
    }

    // Execute move on board
    mutating func executeMove(_ move: Move) {
        let piece = get(at: move.from)
        let pieceColor = piece.color
        unfreeze(for: pieceColor)
        clear(at: move.from)
        update(at: move.to, type: piece.type, color: piece.color)
        atMove = atMove.opponent
        moveNumber += 1
    }

    // Revert move
    mutating func revertMove(_ move: Move) {
        set(move.fromPieceState, at: move.from)
        set(move.toPieceState, at: move.to)
        if let previouslyFrozenPieceIndex = move.previouslyFrozenPieceIndex {
            freezePiece(for: move.fromPieceState.color, at: previouslyFrozenPieceIndex)
        }
        atMove = atMove.opponent
        moveNumber -= 1
    }
    
    // Find piece index
    func findIndex(type: PieceType, color: PieceColor) -> Index? {
        for index in 0..<pieces.count {
            let piece = pieces[index]
            if piece.type == type && piece.color == color {
                return index
            }
        }
        return nil
    }

    // Find king index for color
    func findKingIndex(color: PieceColor) -> Index? {
        findIndex(type: .king, color: color)
    }

    // Check if game is complete
    func gameIsComplete() -> Bool {
        return hasWon(color: .white) || hasWon(color: .black)
    }

    // Check if color has won
    func hasWon(color: PieceColor) -> Bool {
        guard let index = findKingIndex(color: color) else { return false }
        // Check if opponent has no king
        if findKingIndex(color: color.opponent) == nil {
            return true
        }
        // Check if king reached winning rank
        return Self.y(of: index) == Self.winningY(for: color)
    }
}
