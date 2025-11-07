import SwiftUI

struct PieceView: View {
    
    let piece: Piece?
    
    var body: some View {
        if let imageName = piece?.imageName {
            Image(imageName)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
        }
    }
}
