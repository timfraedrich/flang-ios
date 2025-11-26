import Foundation

public struct BoardPosition: Hashable, Sendable {
    
    public let row: Int
    public let col: Int
    
    public var algebraic: String {
        let file = String(UnicodeScalar(UInt8(97 + col))) // 'a' + col
        let rank = row + 1
        return "\(file)\(rank)"
    }

    public init?(row: Int, col: Int) {
        guard (.zero..<Board.boardSize).contains(col), (.zero..<Board.boardSize).contains(row) else { return nil }
        self.row = row
        self.col = col
    }

    public init?(algebraic: String) {
        let algebraic = algebraic.lowercased()
        guard algebraic.count == 2,
              let file = algebraic.first,
              let rank = algebraic.last,
              let col = file.asciiValue.map({ Int($0) - 97 }),
              let row = rank.wholeNumberValue.map({ $0 - 1 })
        else { return nil }
        self.init(row: row, col: col)
    }
    
    var index: Board.Index { row * Board.boardSize + col }
    
    init?(index: Board.Index) {
        self.init(row: index / Board.boardSize, col: index % Board.boardSize)
    }
    
    static func + (lhs: BoardPosition, rhs: Vector) -> BoardPosition? {
        .init(row: lhs.row + rhs.y, col: lhs.col + rhs.x)
    }
}
