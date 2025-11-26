import Foundation

/// COMPLETE API SPEC ENDPOINTS (NOV 2025)

import Foundation

enum APIEndpoint {

    // MARK: - Authentication

    case register
    case newSession
    case login
    case changePassword

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

    // MARK: - Computer

    case getComputerResults(fmn: String)

    // MARK: - Chat

    case getChatMessages(lastMessageDate: Int? = nil, timeout: Int? = nil)
    case sendChatMessage

    // MARK: - Analysis

    case requestAnalysis
    case getAnalysis(id: Int)
    case getAnalysisQuota

    // MARK: - Puzzles

    case getPuzzles
    case solvePuzzle(puzzleId: Int)
    case ratePuzzle(puzzleId: Int)
    case viewPuzzle(puzzleId: Int)

    // MARK: - Other

    case getServerInfo
    case getTVGame
    case queryOpening(fmn: String)
    case getStatistics

    // MARK: - URL Construction
    
    func url(for baseURL: URL) -> URL? {
        var components = URLComponents(string: baseURL.path() + path)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        return components?.url
    }

    private var path: String {
        switch self {
        // Authentication
        case .register: "/register"
        case .newSession: "/newSession"
        case .login: "/login"
        case .changePassword: "/changePassword"

        // Game
        case .getGame(let id, _, _): "/game/\(id)"
        case .executeMove(let id): "/game/move/\(id)"
        case .resignGame(let id): "/game/resign/\(id)"
        case .getActiveGames: "/game/findActive"

        // Game Requests
        case .getGameRequestLobby: "/game/request/lobby"
        case .createLiveGameRequest: "/game/request/add"
        case .acceptLiveGameRequest(let id): "/game/request/accept/\(id)"

        // Daily Games
        case .createDailyGameRequest: "/daily/request/add"
        case .acceptDailyGameRequest(let id): "/daily/request/accept/\(id)"
        case .cancelDailyGameRequest(let id): "/daily/request/cancel/\(id)"

        // User
        case .getUserProfile(let username): "/user/\(username)"
        case .getUserGames(let username, _, _): "/user/\(username)/games"
        case .searchUsers(let username): "/search/\(username)"
        case .getTopPlayers: "/users/top"
        case .getOnlinePlayers: "/users/online"

        // Computer
        case .getComputerResults: "/computer/results"

        // Chat
        case .getChatMessages: "/chat/global/messages"
        case .sendChatMessage: "/chat/global/send"

        // Analysis
        case .requestAnalysis: "/analysis/request"
        case .getAnalysis(let id): "/analysis/\(id)"
        case .getAnalysisQuota: "/analysis/quota"

        // Puzzles
        case .getPuzzles: "/puzzle/getPuzzles"
        case .solvePuzzle(let puzzleId): "/puzzle/\(puzzleId)/solvePuzzle"
        case .ratePuzzle(let puzzleId): "/puzzle/\(puzzleId)/ratePuzzle"
        case .viewPuzzle(let puzzleId): "/puzzle/\(puzzleId)/view"

        // Other
        case .getServerInfo: "/info"
        case .getTVGame: "/tv"
        case .queryOpening: "/opening/query"
        case .getStatistics: "/stats"
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

        case .getComputerResults(let fmn):
            return [URLQueryItem(name: "fmn", value: fmn)]

        case .getChatMessages(let lastMessageDate, let timeout):
            var items: [URLQueryItem] = []
            if let lastMessageDate {
                items.append(URLQueryItem(name: "lastMessageDate", value: "\(lastMessageDate)"))
            }
            if let timeout {
                items.append(URLQueryItem(name: "timeout", value: "\(timeout)"))
            }
            return items

        case .queryOpening(let fmn):
            return [URLQueryItem(name: "fmn", value: fmn)]

        default:
            return []
        }
    }
}

/// UNUSED ENDPOINT CALLS

// MARK: - Computer Analysis

/// Get computer analysis results
public func getComputerResults(fmn: String) async throws -> [ComputerResult] {
    let response: ComputerResultsResponse = try await apiClient.sendRequest(to: .getComputerResults(fmn: fmn))
    return response.results
}

// MARK: - Chat

/// Get chat messages with optional long polling
public func getChatMessages(lastMessageDate: Int? = nil, timeout: Int? = nil) async throws -> [ChatMessage] {
    let response: ChatMessagesResponse = try await apiClient.sendRequest(
        to: .getChatMessages(lastMessageDate: lastMessageDate, timeout: timeout)
    )
    return response.messages
}

func sendChatMessage(text: String, attachedGame: String? = nil) async throws {
    // Base64URL encode the text and attachedGame
    let encodedText = text.data(using: .utf8)?.base64EncodedString()
    let encodedGame: String? = attachedGame?.data(using: .utf8)?.base64EncodedString()
    let params = ChatMessageParameters(text: encodedText, attachedGame: encodedGame)
    try await apiClient.sendRequest(to: .sendChatMessage, parameters: params)
}

// MARK: - Analysis

struct AnalysisRequestParams: Encodable {
    let fmn: String
}

func requestAnalysis(fmn: String) async throws -> AnalysisResponse {
    let params = AnalysisRequestParams(fmn: fmn)
    return try await apiClient.sendRequest(to: .requestAnalysis, parameters: params)
}

func getAnalysis(id: Int) async throws -> AnalysisInfo {
    return try await apiClient.sendRequest(to: .getAnalysis(id: id))
}

func getAnalysisQuota() async throws -> AnalysisQuota {
    return try await apiClient.sendRequest(to: .getAnalysisQuota)
}

// MARK: - Puzzles

func getPuzzles() async throws -> PuzzlesResponse {
    return try await apiClient.sendRequest(to: .getPuzzles)
}

struct PuzzleSolveParams: Encodable {
    let solved: Bool
}

func solvePuzzle(puzzleId: Int, solved: Bool) async throws -> PuzzleSolveResponse {
    let params = PuzzleSolveParams(solved: solved)
    return try await apiClient.sendRequest(to: .solvePuzzle(puzzleId: puzzleId), parameters: params)
}

struct PuzzleRateParams: Encodable {
    let rating: Int
}

func ratePuzzle(puzzleId: Int, rating: Int) async throws {
    let params = PuzzleRateParams(rating: rating)
    try await apiClient.sendRequest(to: .ratePuzzle(puzzleId: puzzleId), parameters: params)
}

func viewPuzzle(puzzleId: Int) async throws -> Puzzle {
    return try await apiClient.sendRequest(to: .viewPuzzle(puzzleId: puzzleId))
}

// MARK: - Other

/// Get server information
func getServerInfo() async throws -> ServerInfo {
    return try await apiClient.sendRequest(to: .getServerInfo)
}

/// Get TV game
func getTVGame() async throws -> TVResponse {
    return try await apiClient.sendRequest(to: .getTVGame)
}

/// Query opening database
func queryOpening(fmn: String) async throws -> OpeningQueryResponse {
    return try await apiClient.sendRequest(to: .queryOpening(fmn: fmn))
}

/// Get server statistics
func getStatistics() async throws -> StatsResponse {
    return try await apiClient.sendRequest(to: .getStatistics)
}
