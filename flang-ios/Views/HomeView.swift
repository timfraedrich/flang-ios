import SwiftUI

struct GameType: Hashable {
    let title: String
    let subtitle: String
}

struct HomeView: View {
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let items: [GameType] = [
        .init(title: "1 min", subtitle: "Bullet"),
        .init(title: "2 min", subtitle: "Bullet"),
        .init(title: "3 min", subtitle: "Blitz"),
        .init(title: "5 min", subtitle: "Blitz"),
        .init(title: "10 min", subtitle: "Rapid"),
        .init(title: "30 min", subtitle: "Classical"),
        .init(title: "1 min", subtitle: "Bot Bullet"),
        .init(title: "5 min", subtitle: "Bot Blitz"),
        .init(title: "15 min", subtitle: "Bot Rapid")
    ]
    
    var body: some View {
        VStack {
            Text("1 players / 0 games in play")
            LazyVGrid(columns: columns) {
                ForEach(items, id: \.self) { gameItem in
                    NavigationLink {
                        GameView()
                    } label: {
                        VStack {
                            Text(gameItem.title)
                                .foregroundStyle(.black)
                            Text(gameItem.subtitle)
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .clipShape(Capsule())
                    .glassEffect(.regular.interactive(), in: .capsule)
                }
            }
            Spacer()
        }
        .padding(16)
    }
}

#Preview {
    HomeView()
}
