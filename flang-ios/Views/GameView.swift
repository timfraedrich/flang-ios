import SwiftUI

struct Action: Equatable, Hashable {
    let name: String
    let symbolName: String
    let action: () -> Void
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(symbolName)
    }
    
    static func == (rhs: Self, lhs: Self) -> Bool {
        return rhs.name == lhs.name && rhs.symbolName == lhs.symbolName
    }
}

struct GameView: View {
    
    @State private var gameState = GameState()
    
    private let actions: [Action] = [
        .init(
            name: "Resign",
            symbolName: "flag.fill",
            action: {}
        ),
        .init(
            name: "Back",
            symbolName: "chevron.backward",
            action: {}
        ),
        .init(
            name: "Forward",
            symbolName: "chevron.forward",
            action: {}
        ),
        .init(
            name: "Analyze",
            symbolName: "compass.drawing",
            action: {}
        ),
        .init(
            name: "Share",
            symbolName: "square.and.arrow.up",
            action: {}
        ),
        .init(
            name: "Hint",
            symbolName: "lightbulb.fill",
            action: {}
        ),
        .init(
            name: "Opening Book",
            symbolName: "text.book.closed.fill",
            action: {}
        ),
        .init(
            name: "Computer analyze",
            symbolName: "chart.bar.yaxis",
            action: {}
        ),
        .init(
            name: "Skip to next puzzle",
            symbolName: "arrow.forward.to.line",
            action: {}
        )
    ]
    
    var body: some View {
        VStack {
            info.rotationEffect(.degrees(180))
            BoardView(gameState: gameState)
            info
            
            actionBar
        }
        .padding()
    }
    
    var actionBar: some View {
        HStack {
            ForEach(actions, id: \.self) { action in
                Spacer()
                Button {
                    action.action()
                } label: {
                    Image(systemName: action.symbolName)
                        .background(.ultraThinMaterial, in: .circle)
                }
                .glassEffect(.regular.interactive(), in: .buttonBorder)
                .frame(width: 16)
            }
            Spacer()
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
    GameView()
}
