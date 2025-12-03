import FlangModel
import SwiftUI

public struct SquareView: View {
    
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    private let position: BoardPosition
    private let boardIsRotated: Bool
    private let isFrozen: Bool
    private let hasPiece: Bool
    private let isSelected: Bool
    private let isLegalMove: Bool
    
    public init(position: BoardPosition, boardIsRotated: Bool, isFrozen: Bool, hasPiece: Bool, isSelected: Bool, isLegalMove: Bool) {
        self.position = position
        self.boardIsRotated = boardIsRotated
        self.isFrozen = isFrozen
        self.hasPiece = hasPiece
        self.isSelected = isSelected
        self.isLegalMove = isLegalMove
    }
    
    private var isLightSquare: Bool { (position.row + position.col) % 2 == 1 }
    private var squareColor: Color { if isLightSquare { .boardWhite } else { .boardBlack } }
    private var textColor: Color { if isLightSquare { .boardBlack } else { .boardWhite } }
    private var numberLabel: String? {
        guard position.col == .zero else { return nil }
        return String(position.row + 1)
    }
    private var letterLabel: String? {
        guard position.row == .zero else { return nil }
        guard let start = Character("A").asciiValue, let scalar = Unicode.Scalar(UInt32(start) + UInt32(position.col)) else { return nil }
        return String(scalar)
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                Rectangle().fill(squareColor)
                
                if isSelected || isLegalMove && hasPiece {
                    Rectangle().fill(Color.fieldMove)
                } else if isLegalMove {
                    Circle().fill(Color.fieldMove).frame(width: proxy.size.width * 0.2, height: proxy.size.height * 0.2)
                } else if isFrozen {
                    Rectangle().fill(Color.fieldFrozen)
                    if differentiateWithoutColor {
                        Image(systemName: "snowflake")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color.white)
                            .padding(proxy.size.width * 0.04)
                    }
                }
                
                if let letterLabel {
                    Text(letterLabel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: boardIsRotated ? .topLeading : .bottomTrailing)
                        .padding(proxy.size.height * 0.04)
                }
                
                if let numberLabel {
                    Text(numberLabel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: boardIsRotated ? .bottomTrailing : .topLeading)
                        .padding(proxy.size.height * 0.04)
                }
            }
            .foregroundStyle(textColor)
            .font(.system(size: proxy.size.height * 0.2, weight: .semibold))
            .lineHeight(.exact(points: proxy.size.height * 0.25))
            .contentShape(Rectangle())
        }
    }
}
