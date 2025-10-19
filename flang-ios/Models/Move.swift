import Foundation

struct Move {
    let from: Board.Index
    let to: Board.Index
    let fromPieceState: PieceState
    let toPieceState: PieceState
    let previouslyFrozenPieceIndex: Board.Index?

    init(from: Board.Index, to: Board.Index, fromPieceState: PieceState, toPieceState: PieceState, previouslyFrozenPieceIndex: Board.Index?) {
        self.from = from
        self.to = to
        self.fromPieceState = fromPieceState
        self.toPieceState = toPieceState
        self.previouslyFrozenPieceIndex = previouslyFrozenPieceIndex
    }

    // Helper to get algebraic notation
    func toAlgebraic() -> String {
        let fromFile = String(UnicodeScalar(UInt8(97 + Board.x(of: from))))
        let fromRank = Board.y(of: from) + 1
        let toFile = String(UnicodeScalar(UInt8(97 + Board.x(of: to))))
        let toRank = Board.y(of: from) + 1
        return "\(fromFile)\(fromRank)\(toFile)\(toRank)"
    }
}
