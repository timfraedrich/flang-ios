import SwiftUI
import FlangModel

public struct PieceView: View {
    
    private let piece: Piece?
    
    public init(piece: Piece?) {
        self.piece = piece
    }
    
    public var body: some View {
        if let imageName = piece?.imageName,
           let url = Bundle.module.url(forResource: imageName, withExtension: "png"),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
        }
    }
}
