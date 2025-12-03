public enum GameObjective: Hashable, Sendable {
    /// There is no objective, the game continues forever.
    case none
    /// Require some piece of the specified color to move to the specified position.
    case claimPosition(PieceColor, BoardPosition)
    /// The default Flang objective is to capture the opponents king or reach the other side of the board, with your own king.
    case `default`
    
    func winner(for board: Board) -> PieceColor? {
        switch self {
        case .none:
            return nil
        case let .claimPosition(color, position):
            let piece = board.piece(at: position)
            return piece.type != .none && piece.color == color ? color : nil
        case .default:
            guard let whiteKing = board.findPiece(of: .king, and: .white) else { return .black }
            guard let blackKing = board.findPiece(of: .king, and: .black) else { return .white }
            return if whiteKing.row == Board.opponentsBaseRow(for: .white) {
                .white
            } else if blackKing.row == Board.opponentsBaseRow(for: .black) {
                .black
            } else {
                nil
            }
        }
    }
}
