import FlangModel
import FlangOnline
import SwiftUI

@main
struct FlangApp: App {

    @State private var flangOnline = try? FlangOnline()
    @State private var router = Router()

    var body: some Scene {
        WindowGroup {
            if let flangOnline {
                NavigationStack(path: $router.path) {
                    MainMenuScene()
                        .navigationDestination(for: NavigationDestination.self) { destination in
                            switch destination {
                            case .community:
                                CommunityScene()
                            case .lobby:
                                LobbyScene()
                            case .createOnlineGameRequest:
                                CreateOnlineGameRequestScene()
                            case .game(let game):
                                GameScene(game: game ?? .init())
                            case .onlineGame(let id):
                                OnlineGameScene(gameId: id)
                            case .playerProfile(let username):
                                PlayerProfileScene(username: username)
                            }
                        }
                        .sheet(isPresented: $router.showAuthentication) {
                            AuthenticationScene()
                        }
                }
                .environment(flangOnline.sessionManager)
                .environment(flangOnline.communityService)
                .environment(flangOnline.onlineGameService)
                .environment(router)
            } else {
                Text("Error: Could not initialize FlangOnline")
            }
        }
    }
}
