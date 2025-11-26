import FlangModel

enum NavigationDestination: Hashable {
    case community
    case lobby
    case createOnlineGameRequest
    case game(Game?)
    case onlineGame(id: Int)
    case playerProfile(username: String)
}
