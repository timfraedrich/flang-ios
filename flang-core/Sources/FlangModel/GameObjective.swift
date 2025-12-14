public enum GameObjective: Hashable, Sendable {
    /// There is no objective, the game continues forever.
    case none
    /// Require some piece of the specified color to move to the specified position.
    case claimPosition(PieceColor, BoardPosition)
    /// Capture the opponents king.
    case captureKing
    /// Reach the other side of the board with your king.
    case reachOtherSide
    /// The default Flang objective is to capture the opponents king or reach the other side of the board, with your own king.
    case `default`
    
    func winner(for board: Board) -> PieceColor? {
        switch self {
        case .none:
            return nil
        case let .claimPosition(color, position):
            let piece = board.piece(at: position)
            return piece.type != .none && piece.color == color ? color : nil
        case .captureKing:
            guard let whiteKing = board.findPiece(of: .king, and: .white) else { return .black }
            guard let blackKing = board.findPiece(of: .king, and: .black) else { return .white }
            return nil
        case .reachOtherSide:
            return if let whiteKing = board.findPiece(of: .king, and: .white), whiteKing.row == Board.opponentsBaseRow(for: .white) {
                .white
            } else if let blackKing = board.findPiece(of: .king, and: .black), blackKing.row == Board.opponentsBaseRow(for: .black) {
                .black
            } else {
                nil
            }
        case .default:
            return GameObjective.captureKing.winner(for: board) ?? GameObjective.reachOtherSide.winner(for: board)
        }
    }
}
