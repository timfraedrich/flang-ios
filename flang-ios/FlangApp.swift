import FlangModel
import FlangOnline
import SwiftUI

@main
struct FlangApp: App {

    @State private var flangOnline: FlangOnline?
    @State private var router: Router
    @Environment(\.openURL) var openURL

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
                        .sheet(item: $router.currentSheet) { sheet in
                            NavigationStack {
                                switch sheet {
                                case .tutorial:
                                    TutorialScene()
                                case .authentication:
                                    AuthenticationScene()
                                case .settings:
                                    SettingsScene()
                                }
                            }
                        }
                }
                .environment(flangOnline.sessionManager)
                .environment(flangOnline.communityService)
                .environment(flangOnline.onlineGameService)
                .environment(router)
            } else {
                Text("flang_online_init_error")
            }
        }
    }
    
    init() {
        flangOnline = try? FlangOnline()
        let routerSheets: [SheetDestination] = if !UserDefaults.standard.hasFinishedTutorial { [.tutorial] } else { [] }
        router = .init(sheets: routerSheets)
    }
}
