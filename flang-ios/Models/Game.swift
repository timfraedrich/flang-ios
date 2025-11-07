import Foundation

struct Game: Equatable {
    
    private(set) var board: Board
    private(set) var atMove: PieceColor
    /// Intuitively the number of steps the board is currently reverted backward
    private(set) var historyOffset: UInt = .zero
    private var history: [HistoryEntry] = []
    
    // MARK: - Computed Properties
    
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
