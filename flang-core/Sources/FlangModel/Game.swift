import Foundation

public struct Game: Hashable, Sendable {
    
    private let initialBoard: Board
    private let initialAtMove: PieceColor
    public private(set) var board: Board
    public let objective: GameObjective
    public private(set) var atMove: PieceColor
    /// Indicates whether the color at move changes; If not, the initial color is at move for the entire game.
    public let takeTurns: Bool
    /// Indicates whether pieces (except the king) should be frozen after the got moved.
    public let freezePieces: Bool
    /// Intuitively the number of steps the board is currently reverted backward
    private var historyOffset: UInt = .zero
    private var history: [HistoryEntry] = []
    
    // MARK: - Computed Properties
    
    public var hasHistory: Bool { !history.isEmpty }
    public var backEnabled: Bool { historyOffset < history.count }
    public var forwardEnabled: Bool { historyOffset > 0 }
    
    public var winner: PieceColor? {
        let lastHistoryEntryIndex = history.count - Int(historyOffset) - 1
        return if lastHistoryEntryIndex >= .zero, case .resign(let color) = history[lastHistoryEntryIndex].action {
            color.opponent
        } else {
            objective.winner(for: board)
        }
    }
    
    // MARK: - Initialization
    
    public init(
        board: Board = .defaultPosition(),
        objective: GameObjective = .default,
        atMove: PieceColor = .white,
        takeTurns: Bool = true,
        freezePieces: Bool = true
    ) {
        self.initialBoard = board
        self.board = board
        self.objective = objective
        self.initialAtMove = atMove
        self.atMove = atMove
        self.takeTurns = takeTurns
        self.freezePieces = freezePieces
    }
    
    // MARK: - Actions
    
    @discardableResult
    private mutating func moveOnBoard(from: BoardPosition, to: BoardPosition) throws -> HistoryEntry {
        let piece = board[from]
        let takenPiece = try board.move(from: from, to: to)
        var promoted: Bool = false
        if piece.type == .pawn, to.row == Board.opponentsBaseRow(for: piece.color) {
            try board.promotePawn(at: to)
            promoted = true
        }
        let previouslyFrozenPosition = board.unfreeze(atMove)
        if freezePieces, piece.type != .king {
            try board.freeze(at: to)
        }
        if takeTurns {
            atMove = atMove.opponent
        }
        return .init(action: .move(from: from, to: to), promoted: promoted, captured: takenPiece, previouslyFrozenPosition: previouslyFrozenPosition)
    }
    
    public mutating func perform(_ action: Action) throws {
        let moveGenerator = MoveGenerator(board: board)
        guard moveGenerator.isLegalMove(action, for: atMove) else { throw Error.illegalMove }
        if historyOffset > .zero {
            history.removeLast(Int(historyOffset))
            historyOffset = .zero
        }
        switch action {
        case .move(let from, let to):
            let entry = try moveOnBoard(from: from, to: to)
            history.append(entry)
        case .resign:
            history.append(.init(action: action, promoted: false, captured: nil, previouslyFrozenPosition: nil))
        }
    }
    
    public mutating func back() throws {
        guard backEnabled else { throw Error.cannotGoBack }
        let newHistoryOffset = historyOffset + 1
        let historyEntryToRevertTo = history[history.count - Int(newHistoryOffset)]
        switch historyEntryToRevertTo.action {
        case .move(let from, let to):
            if historyEntryToRevertTo.promoted {
                try board.demoteUni(at: to)
            }
            try board.revert(from: from, to: to, reinstate: historyEntryToRevertTo.captured)
            if takeTurns {
                atMove = atMove.opponent
            }
            board.unfreeze(atMove)
            if let previouslyFrozenPosition = historyEntryToRevertTo.previouslyFrozenPosition {
                try board.freeze(at: previouslyFrozenPosition)
            }
        case .resign:
            break
        }
        historyOffset = newHistoryOffset
    }
    
    public mutating func forward() throws {
        guard forwardEnabled else { throw Error.cannotGoForward }
        let newHistoryOffset = historyOffset - 1
        let historyEntryToMoveTo = history[history.count - Int(newHistoryOffset) - 1]
        switch historyEntryToMoveTo.action {
        case .move(let from, let to):
            try moveOnBoard(from: from, to: to)
        case .resign:
            break
        }
        historyOffset = newHistoryOffset
    }
    
    // MARK: - Actions

    /// Get all legal move actions for the current player
    public func legalMoveActions() -> [Action] {
        let moveGenerator = MoveGenerator(board: board)
        return moveGenerator.generateMoves(for: atMove)
    }

    /// Get all legal target squares for a piece at a given position
    public func legalTargets(for position: BoardPosition) -> [BoardPosition] {
        let moveGenerator = MoveGenerator(board: board)
        return moveGenerator.legalTargets(forPieceAt: position)
    }

    /// Check if an action is legal for the current player
    public func isLegalAction(_ action: Action) -> Bool {
        let moveGenerator = MoveGenerator(board: board)
        return moveGenerator.isLegalMove(action, for: atMove)
    }

    /// Reset the game to the starting position
    public mutating func reset() throws {
        while backEnabled { try back() }
        history.removeAll()
        historyOffset = .zero
    }
    
    // MARK: - History
    
    private struct HistoryEntry: Hashable {
        let action: Action
        let promoted: Bool
        let captured: Piece?
        let previouslyFrozenPosition: BoardPosition?
    }
    
    // MARK: - Error

    public enum Error: Swift.Error {
        case illegalMove
        case cannotGoBack
        case cannotGoForward
    }

    // MARK: - FBN (Flang Board Notation)

    /// Export current board state to FBN (Flang Board Notation) v2
    /// - Returns: FBN string representing the current board and color to move
    public func toFBN() -> String {
        var result = ""

        // Add color prefix
        result.append(atMove == .white ? "+" : "-")

        // Encode board pieces
        var emptyCount = 0

        for index in 0..<Board.arraySize {
            let piece = board.pieces[index]

            if piece.type == .none {
                emptyCount += 1
            } else {
                // Flush empty count if any
                if emptyCount > 0 {
                    result.append(String(emptyCount))
                    emptyCount = 0
                }

                // Add piece character
                result.append(piece.type.character(for: piece.color))

                // Add freeze marker if frozen
                if piece.frozen {
                    result.append("-")
                }
            }
        }

        // Flush remaining empty count
        if emptyCount > 0 {
            result.append(String(emptyCount))
        }

        return result
    }

    /// Initialize game from FBN (Flang Board Notation)
    /// Creates a new game at the specified board position
    /// - Parameter fbn: FBN string with color prefix and board state
    public init?(fromFBN fbn: String) {
        guard !fbn.isEmpty else { return nil }

        // Parse color prefix
        let colorChar = fbn.first!
        let color: PieceColor
        switch colorChar {
        case "+": color = .white
        case "-": color = .black
        default: return nil
        }

        // Parse board using helper initializer
        let fbnPieces = String(fbn.dropFirst())
        guard let board = Board(fromFBNPieces: fbnPieces) else { return nil }

        self.init(board: board, atMove: color)
    }

    // MARK: - FMN (Flang Move Notation) v2

    /// Export game to FMN (Flang Move Notation) v2
    /// Returns the sequence of moves from the start position
    /// - Returns: Space-separated FMN string of all moves
    public func toFMN() throws -> String {
        // We need to replay the game from the beginning to generate proper notation
        var game = Game(board: .defaultPosition(), atMove: .white)
        var moveStrings: [String] = []

        // Get the moves up to current point (excluding any forward history if we've gone back)
        let relevantHistoryCount = history.count - Int(historyOffset)

        for i in 0..<relevantHistoryCount {
            let action = history[i].action
            let notation = try action.shortNotation(on: game.board, atMove: game.atMove)
            moveStrings.append(notation)

            // Perform the move to update board state for next iteration
            try game.perform(action)
        }

        return moveStrings.joined(separator: " ")
    }

    /// Initialize game from FMN (Flang Move Notation) string
    /// Assumes starting from the default position
    /// - Parameter fmn: Space-separated FMN string
    public init?(fromFMN fmn: String) {
        self.init(board: .defaultPosition(), atMove: .white)

        let moveStrings = fmn.split(separator: " ").map(String.init)

        for moveString in moveStrings {
            guard let action = Action.parse(moveString, on: board, atMove: atMove) else {
                return nil
            }

            do {
                try perform(action)
            } catch {
                return nil
            }
        }
    }

    // MARK: - FMNe (Flang Move Notation Extended)

    /// Character mapping for FMNe: a-z, A-Z, 0-9, +, - (64 chars)
    private static let fmneCharacters: [Character] = {
        let lowercase = Array("abcdefghijklmnopqrstuvwxyz")
        let uppercase = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let digits = Array("0123456789")
        let special: [Character] = ["+", "-"]
        return lowercase + uppercase + digits + special
    }()

    private static let fmneCharToIndex: [Character: Int] = {
        Dictionary(uniqueKeysWithValues: fmneCharacters.enumerated().map { ($1, $0) })
    }()

    /// Convert index (0-63) to FMNe character
    private static func fmneChar(for index: Int) -> Character? {
        guard index >= 0 && index < 64 else { return nil }
        return fmneCharacters[index]
    }

    /// Convert FMNe character to index (0-63)
    private static func fmneIndex(for char: Character) -> Int? {
        fmneCharToIndex[char]
    }

    /// Sort actions by fromIndex * 64 + toIndex for FMNe encoding
    private static func sortedActions(_ actions: [Action]) -> [Action] {
        actions.sorted { action1, action2 in
            guard case .move(let from1, let to1) = action1,
                  case .move(let from2, let to2) = action2 else {
                return false
            }
            let key1 = from1.index * 64 + to1.index
            let key2 = from2.index * 64 + to2.index
            return key1 < key2
        }
    }

    /// Export game to FMNe (Flang Move Notation Extended)
    /// Returns compact alphanumeric encoding of all moves
    /// - Returns: FMNe string starting with "!"
    public func toFMNe() throws -> String {
        var result = "!"

        // Replay the game from the beginning
        var game = Game(board: .defaultPosition(), atMove: .white)
        let moveGenerator = MoveGenerator(board: game.board)

        let relevantHistoryCount = history.count - Int(historyOffset)

        for i in 0..<relevantHistoryCount {
            let action = history[i].action

            // Handle resignation
            if case .resign = action {
                result.append(try action.notation(on: game.board))
                try game.perform(action)
                continue
            }

            // Update move generator with current board state
            moveGenerator.updateBoard(game.board)

            // Generate and sort possible moves
            let possibleMoves = moveGenerator.generateMoves(for: game.atMove)
            let sortedMoves = Self.sortedActions(possibleMoves)

            if sortedMoves.count < 64 {
                // Use single character encoding
                guard let moveIndex = sortedMoves.firstIndex(of: action) else {
                    throw NotationError.invalidMove
                }
                guard let char = Self.fmneChar(for: moveIndex) else {
                    throw NotationError.encodingError
                }
                result.append(char)
            } else {
                // Use two character encoding (from + to indices)
                guard case .move(let from, let to) = action else {
                    throw NotationError.invalidMove
                }
                guard let fromChar = Self.fmneChar(for: from.index), let toChar = Self.fmneChar(for: to.index)
                else { throw NotationError.encodingError }
                result.append(fromChar)
                result.append(toChar)
            }

            // Perform the move to update board state for next iteration
            try game.perform(action)
        }

        return result
    }

    /// Initialize game from FMNe (Flang Move Notation Extended) string
    /// Assumes starting from the default position
    /// - Parameter fmne: FMNe string starting with "!"
    public init?(fromFMNe fmne: String) {
        guard fmne.first == "!", fmne.count > 1 else {
            return nil
        }
        
        self.init(board: .defaultPosition(), atMove: .white)
        let moveGenerator = MoveGenerator(board: board)
        
        var index = fmne.index(after: fmne.startIndex)
        
        while index < fmne.endIndex {
            let char = fmne[index]
            
            // Handle resignation
            if char == "#" {
                guard fmne.index(after: index) < fmne.endIndex else {
                    return nil
                }
                let nextIndex = fmne.index(after: index)
                let colorChar = fmne[nextIndex]
                let action: Action?
                switch colorChar {
                case "+": action = .resign(color: .white)
                case "-": action = .resign(color: .black)
                default: action = nil
                }
                
                guard let action else {
                    return nil
                }
                
                do {
                    try perform(action)
                } catch {
                    return nil
                }
                
                index = fmne.index(after: nextIndex)
                continue
            }
            
            // Generate and sort possible moves
            moveGenerator.updateBoard(board)
            let possibleMoves = moveGenerator.generateMoves(for: atMove)
            let sortedMoves = Self.sortedActions(possibleMoves)
            
            let action: Action
            
            if sortedMoves.count < 64 {
                // Single character encoding
                guard let moveIndex = Self.fmneIndex(for: char) else {
                    return nil
                }
                guard moveIndex < sortedMoves.count else {
                    return nil
                }
                action = sortedMoves[moveIndex]
                index = fmne.index(after: index)
            } else {
                // Two character encoding
                guard let fromIndex = Self.fmneIndex(for: char), let fromPosition = BoardPosition(index: fromIndex) else {
                    return nil
                }
                guard fmne.index(after: index) < fmne.endIndex else {
                    return nil
                }
                
                let nextIndex = fmne.index(after: index)
                let toChar = fmne[nextIndex]
                guard let toIndex = Self.fmneIndex(for: toChar), let toPosition = BoardPosition(index: toIndex) else {
                    return nil
                }
                
                action = .move(from: fromPosition, to: toPosition)
                index = fmne.index(after: nextIndex)
            }
            
            do {
                try perform(action)
            } catch {
                return nil
            }
        }
    }

    public enum NotationError: Swift.Error {
        case invalidMove
        case encodingError
    }
    
    public static func isMoveEquivalent(_ lhs: Game, _ rhs: Game) -> Bool {
        lhs.initialAtMove == rhs.initialAtMove && lhs.initialBoard == rhs.initialBoard && lhs.history == rhs.history
    }
}
