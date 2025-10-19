import SwiftUI

struct ContentView: View {
    
    @State private var gameState = GameState()
    
    var body: some View {
        NavigationStack {
            VStack {
                info.rotationEffect(.degrees(180))
                BoardView(gameState: gameState)
                info
            }
            .padding()
        }
    }
    
    var info: some View {
        HStack {
            Text("Turn \(gameState.board.moveNumber + 1)").font(.headline)
            Spacer()
            Circle()
                .fill(gameState.board.atMove == .white ? .white : .black)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(.gray, lineWidth: 1)
                )
            Text(gameState.board.atMove == .white ? "White" : "Black")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
