import SwiftUI
import FlangModel

public struct BoardView: View {

    private let board: Board
    private let selectedPosition: BoardPosition?
    private let legalMoves: Set<BoardPosition>
    private let perspective: Perspective
    private var positionTapAction: ((BoardPosition) -> Void)?
    
    private var rows: [[BoardPosition]] {
        perspective.rotateBoard ? Board.rows.map { $0.reversed() } : Board.rows.reversed()
    }
    
    public init(
        board: Board,
        selectedPosition: BoardPosition? = nil,
        legalMoves: Set<BoardPosition> = [],
        perspective: Perspective = .singlePlayerWhite,
        onPositionTapped positionTapAction: ((BoardPosition) -> Void)? = nil
    ) {
        self.board = board
        self.selectedPosition = selectedPosition
        self.legalMoves = legalMoves
        self.perspective = perspective
        self.positionTapAction = positionTapAction
    }
    
    public init(gameState: GameState, perspective: Perspective, onPositionTapped positionTapAction: ((BoardPosition) -> Void)? = nil) {
        self.init(
            board: gameState.board,
            selectedPosition: gameState.selectedPosition,
            legalMoves: gameState.legalMoves,
            perspective: perspective,
            onPositionTapped: positionTapAction ?? { pos in gameState.selectPosition(pos) }
        )
    }

    public var body: some View {
        GeometryReader { proxy in
            VStack(spacing: .zero) {
                ForEach(rows, id: \.hashValue) { row in
                    HStack(spacing: .zero) {
                        ForEach(row, id: \.self) { pos in
                            ZStack {
                                let piece = board.piece(at: pos)
                                SquareView(
                                    position: pos,
                                    boardIsRotated: perspective.rotateBoard,
                                    isFrozen: piece.frozen,
                                    hasPiece: piece.type != .none,
                                    isSelected: selectedPosition == pos,
                                    isLegalMove: legalMoves.contains(pos)
                                )
                                if piece.type != .none {
                                    PieceView(piece: piece).rotationEffect(.degrees(perspective.shouldRotatePiece(of: piece.color) ? 180 : 0))
                                }
                            }
                            .onTapGesture { positionTapAction?(pos) }
                        }
                    }
                }
            }
            .clipShape(.containerRelative)
            .aspectRatio(1, contentMode: .fit)
            .padding(min(proxy.size.width, proxy.size.height) / 32)
            .background(ignoresSafeAreaEdges: [])
            .containerShape(.rect(cornerRadius: min(proxy.size.width, proxy.size.height) / 20))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
    
    public enum Perspective: Hashable {
        case singlePlayerWhite
        case singlePlayerBlack
        case multiplayerWhite
        case multiplayerBlack
        
        public var firstPlayerColor: PieceColor {
            switch self {
            case .singlePlayerWhite, .multiplayerWhite: .white
            case .singlePlayerBlack, .multiplayerBlack: .black
            }
        }
        
        var rotateBoard: Bool { self == .singlePlayerBlack || self == .multiplayerBlack }
        var rotateWhitePieces: Bool { self == .multiplayerBlack }
        var rotateBlackPieces: Bool { self == .multiplayerWhite }
        
        func shouldRotatePiece(of color: PieceColor) -> Bool {
            switch color {
            case .white: rotateWhitePieces
            case .black: rotateBlackPieces
            }
        }
        
        public var rotated: Perspective {
            switch self {
            case .singlePlayerWhite: .singlePlayerBlack
            case .singlePlayerBlack: .singlePlayerWhite
            case .multiplayerWhite: .multiplayerBlack
            case .multiplayerBlack: .multiplayerWhite
            }
        }
        
        public mutating func rotate() {
            self = rotated
        }
    }
}

#Preview {
    VStack(alignment: .center) {
        BoardView(board: .defaultPosition(), perspective: .singlePlayerWhite)
        BoardView(board: .defaultPosition(), perspective: .singlePlayerBlack)
        BoardView(board: .defaultPosition(), perspective: .multiplayerWhite)
        BoardView(board: .defaultPosition(), perspective: .multiplayerBlack)
    }
    .backgroundStyle(.background.secondary)
}
