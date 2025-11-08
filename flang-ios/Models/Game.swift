import Foundation

struct Game: Equatable {
    
    private(set) var board: Board
    private(set) var atMove: PieceColor
    /// Intuitively the number of steps the board is currently reverted backward
    private(set) var historyOffset: UInt = .zero
    private var history: [HistoryEntry] = []
    
    // MARK: - Computed Properties
    
    var hasHistory: Bool { !history.isEmpty }
    var backEnabled: Bool { historyOffset < history.count }
    var forwardEnabled: Bool { historyOffset > 0 }
    
    var winner: PieceColor? {
        let lastHistoryEntryIndex = history.count - Int(historyOffset) - 1
        return if lastHistoryEntryIndex >= .zero, case .resign(let color) = history[lastHistoryEntryIndex].action {
            color.opponent
        } else {
            board.winner
        }
    }
    
    // MARK: - Initialization
    
    init(board: Board = .defaultPosition(), atMove: PieceColor = .white) {
        self.board = board
        self.atMove = atMove
    }
    
    // MARK: - Actions
    
    mutating func perform(_ action: Action) throws {
        let moveGenerator = MoveGenerator(board: board)
        guard moveGenerator.isLegalMove(action, for: atMove) else { throw Error.illegalMove }
        if historyOffset > .zero {
            history.removeLast(Int(historyOffset))
            historyOffset = .zero
        }
        switch action {
        case .move(let from, let to):
            let frozenPieceIndex = board.frozenPieceIndex(for: atMove)
            let (takenPiece, promoted) = try board.move(from: from, to: to)
            history.append(.init(action: action, promoted: promoted, captured: takenPiece, previouslyFrozenIndex: frozenPieceIndex))
            atMove = atMove.opponent
        case .resign:
            history.append(.init(action: action, promoted: false, captured: nil, previouslyFrozenIndex: nil))
        }
    }
    
    mutating func back() throws {
        guard backEnabled else { throw Error.cannotGoBack }
        let newHistoryOffset = historyOffset + 1
        let historyEntryToRevertTo = history[history.count - Int(newHistoryOffset)]
        switch historyEntryToRevertTo.action {
        case .move(let from, let to):
            let previouslyFrozenIndex = historyEntryToRevertTo.previouslyFrozenIndex
            let captured = historyEntryToRevertTo.captured
            try board.revert(from: from, to: to, freeze: previouslyFrozenIndex, reinstate: captured)
            atMove = atMove.opponent
        case .resign:
            break
        }
        historyOffset = newHistoryOffset
    }
    
    mutating func forward() throws {
        guard forwardEnabled else { throw Error.cannotGoForward }
        let newHistoryOffset = historyOffset - 1
        let historyEntryToMoveTo = history[history.count - Int(newHistoryOffset) - 1]
        switch historyEntryToMoveTo.action {
        case .move(let from, let to):
            try board.move(from: from, to: to)
            atMove = atMove.opponent
        case .resign:
            break
        }
        historyOffset = newHistoryOffset
    }
    
    // MARK: - Actions

    /// Get all legal actions for the current player
    func legalActions() -> [Action] {
        let moveGenerator = MoveGenerator(board: board)
        return moveGenerator.generateMoves(for: atMove)
    }

    /// Get all legal target squares for a piece at a given position
    func legalTargets(for index: Board.Index) -> [Board.Index] {
        let moveGenerator = MoveGenerator(board: board)
        return moveGenerator.legalTargets(for: index)
    }

    /// Check if an action is legal for the current player
    func isLegalAction(_ action: Action) -> Bool {
        let moveGenerator = MoveGenerator(board: board)
        return moveGenerator.isLegalMove(action, for: atMove)
    }

    /// Reset the game to the starting position
    mutating func reset() throws {
        while backEnabled { try back() }
        history.removeAll()
        historyOffset = .zero
    }
    
    // MARK: - History
    
    private struct HistoryEntry: Equatable {
        let action: Action
        let promoted: Bool
        let captured: Piece?
        let previouslyFrozenIndex: Board.Index?
    }
    
    // MARK: - Error

    private enum Error: Swift.Error {
        case illegalMove
        case cannotGoBack
        case cannotGoForward
    }
}

// MARK: - Notation Extensions

extension Game {

    // MARK: - FBN (Flang Board Notation)

    /// Export current board state to FBN (Flang Board Notation) v2
    /// - Returns: FBN string representing the current board and color to move
    func toFBN() -> String {
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
    init?(fromFBN fbn: String) {
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
    func toFMN() throws -> String {
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
    init?(fromFMN fmn: String) {
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
            let key1 = from1 * 64 + to1
            let key2 = from2 * 64 + to2
            return key1 < key2
        }
    }

    /// Export game to FMNe (Flang Move Notation Extended)
    /// Returns compact alphanumeric encoding of all moves
    /// - Returns: FMNe string starting with "!"
    func toFMNe() throws -> String {
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
            moveGenerator.board = game.board

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
                guard let fromChar = Self.fmneChar(for: from),
                      let toChar = Self.fmneChar(for: to) else {
                    throw NotationError.encodingError
                }
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
    init?(fromFMNe fmne: String) {
        guard fmne.first == "!", fmne.count > 1 else { return nil }

        self.init(board: .defaultPosition(), atMove: .white)
        let moveGenerator = MoveGenerator(board: board)

        var index = fmne.index(after: fmne.startIndex)

        while index < fmne.endIndex {
            let char = fmne[index]

            // Handle resignation
            if char == "#" {
                guard fmne.index(after: index) < fmne.endIndex else { return nil }
                let nextIndex = fmne.index(after: index)
                let colorChar = fmne[nextIndex]
                let action: Action?
                switch colorChar {
                case "+": action = .resign(color: .white)
                case "-": action = .resign(color: .black)
                default: action = nil
                }

                guard let action else { return nil }

                do {
                    try perform(action)
                } catch {
                    return nil
                }

                index = fmne.index(after: nextIndex)
                continue
            }

            // Generate and sort possible moves
            moveGenerator.board = board
            let possibleMoves = moveGenerator.generateMoves(for: atMove)
            let sortedMoves = Self.sortedActions(possibleMoves)

            let action: Action

            if sortedMoves.count < 64 {
                // Single character encoding
                guard let moveIndex = Self.fmneIndex(for: char) else { return nil }
                guard moveIndex < sortedMoves.count else { return nil }
                action = sortedMoves[moveIndex]
                index = fmne.index(after: index)
            } else {
                // Two character encoding
                guard let fromIndex = Self.fmneIndex(for: char) else { return nil }
                guard fmne.index(after: index) < fmne.endIndex else { return nil }

                let nextIndex = fmne.index(after: index)
                let toChar = fmne[nextIndex]
                guard let toIndex = Self.fmneIndex(for: toChar) else { return nil }

                action = .move(from: fromIndex, to: toIndex)
                index = fmne.index(after: nextIndex)
            }

            do {
                try perform(action)
            } catch {
                return nil
            }
        }
    }

    enum NotationError: Swift.Error {
        case invalidMove
        case encodingError
    }
}
