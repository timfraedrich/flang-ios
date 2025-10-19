import SwiftUI

struct SquareView: View {
    
    let position: BoardPosition
    let piece: Piece?
    let isSelected: Bool
    let isLegalMove: Bool
    
    private var isLightSquare: Bool { (position.row + position.col) % 2 == 1 }
    private var squareColor: Color { if isLightSquare { .boardWhite } else { .boardBlack } }
    private var textColor: Color { if isLightSquare { .boardBlack } else { .boardWhite } }
    private var hasPiece: Bool { piece != nil }
    private var isFrozen: Bool { piece?.frozen == true }
    private var numberLabel: String? {
        guard position.col == .zero else { return nil }
        return String(position.row + 1)
    }
    private var letterLabel: String? {
        guard position.row == .zero else { return nil }
        guard let start = Character("A").asciiValue, let scalar = Unicode.Scalar(UInt32(start) + UInt32(position.col)) else { return nil }
        return String(scalar)
    }
    

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Rectangle().fill(squareColor)
                
                if isSelected {
                    Rectangle().fill(.fieldSelected)
                } else if isLegalMove && hasPiece {
                    Rectangle().fill(.fieldMove)
                } else if isLegalMove {
                    Circle()
                        .fill(.fieldMove)
                        .frame(width: proxy.size.width * 0.4, height: proxy.size.height * 0.4)
                } else if isFrozen {
                    Rectangle().fill(.fieldFrozen)
                }
                
                if let imageName = piece?.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                }
                
                if let letterLabel {
                    Text(letterLabel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .padding(proxy.size.height * 0.04)
                }
                
                if let numberLabel {
                    Text(numberLabel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
