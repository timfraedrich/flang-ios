import Foundation

enum APIEndpoint {

    // MARK: - Authentication

    case register
    case newSession
    case login
    case changePassword
    case deleteAccount

    // MARK: - Game

    case getGame(id: Int, moves: Int? = nil, timeout: Int? = nil)
    case executeMove(id: Int)
    case resignGame(id: Int)
    case getActiveGames

    // MARK: - Game Requests

    case getGameRequestLobby
    case createLiveGameRequest
    case acceptLiveGameRequest(id: Int)
    case createDailyGameRequest
    case acceptDailyGameRequest(id: Int)
    case cancelDailyGameRequest(id: Int)

    // MARK: - User

    case getUserProfile(username: String)
    case getUserGames(username: String, max: Int? = nil, offset: Int? = nil)
    case searchUsers(username: String)
    case getTopPlayers
    case getOnlinePlayers

    // MARK: - URL Construction
    
    func url(for baseURL: URL) -> URL? {
        var components = URLComponents(string: baseURL.absoluteString + path)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        return components?.url
    }

    private var path: String {
        switch self {
        case .register: "/register"
        case .newSession: "/newSession"
        case .login: "/login"
        case .changePassword: "/changePassword"
        case .deleteAccount: "/account/submitDeletionHashed"
        case .getGame(let id, _, _): "/game/\(id)"
        case .executeMove(let id): "/game/move/\(id)"
        case .resignGame(let id): "/game/resign/\(id)"
        case .getActiveGames: "/game/findActive"
        case .getGameRequestLobby: "/game/request/lobby"
        case .createLiveGameRequest: "/game/request/add"
        case .acceptLiveGameRequest(let id): "/game/request/accept/\(id)"
        case .createDailyGameRequest: "/daily/request/add"
        case .acceptDailyGameRequest(let id): "/daily/request/accept/\(id)"
        case .cancelDailyGameRequest(let id): "/daily/request/cancel/\(id)"
        case .getUserProfile(let username): "/user/\(username)"
        case .getUserGames(let username, _, _): "/user/\(username)/games"
        case .searchUsers(let username): "/search/\(username)"
        case .getTopPlayers: "/users/top"
        case .getOnlinePlayers: "/users/online"
        }
    }

    private var queryItems: [URLQueryItem] {
        switch self {
        case .getGame(_, let moves, let timeout):
            var items: [URLQueryItem] = []
            if let moves {
                items.append(URLQueryItem(name: "moves", value: "\(moves)"))
            }
            if let timeout {
                items.append(URLQueryItem(name: "timeout", value: "\(timeout)"))
            }
            return items

        case .getUserGames(_, let max, let offset):
            var items: [URLQueryItem] = []
            if let max {
                items.append(URLQueryItem(name: "max", value: "\(max)"))
            }
            if let offset {
                items.append(URLQueryItem(name: "offset", value: "\(offset)"))
            }
            return items
        default:
            return []
        }
    }
}
