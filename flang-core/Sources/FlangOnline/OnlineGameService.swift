import Foundation
import Observation

@MainActor
@Observable
public class OnlineGameService {
    
    private let apiClient: APIClient
    private let sessionManager: SessionManager
    
    init(apiClient: APIClient, sessionManager: SessionManager) {
        self.apiClient = apiClient
        self.sessionManager = sessionManager
    }

    // MARK: - Game Operations

    /// Get game information with optional long polling
    public func getGame(id: Int, expectedMoves: Int? = nil, timeout: Int? = nil) async throws -> OnlineGameInfo {
        try await apiClient.sendRequest(to: .getGame(id: id, moves: expectedMoves, timeout: timeout))
    }

    /// Execute a move in a game
    public func executeMove(gameId: Int, move: String) async throws {
        try await sessionManager.checkSessionValidity()
        let params = MoveParameters(moveStr: move)
        try await apiClient.sendRequest(to: .executeMove(id: gameId), parameters: params)
    }

    /// Resign from a game
    public func resignGame(id: Int) async throws {
        try await sessionManager.checkSessionValidity()
        try await apiClient.sendRequest(to: .resignGame(id: id))
    }

    /// Find active games for the current user
    public func getActiveGames() async throws -> [OnlineGameInfo] {
        try await sessionManager.checkSessionValidity()
        let response: GamesResponse = try await apiClient.sendRequest(to: .getActiveGames)
        return response.games
    }

    // MARK: - Live Games

    /// Get lobby with active game requests for the current user.
    public func getGameRequestLobby() async throws -> OnlineGameRequestLobby {
        try await sessionManager.checkSessionValidity()
        let response: LobbyResponse = try await apiClient.sendRequest(to: .getGameRequestLobby)
        return .init(liveRequests: response.requests, dailyRequests: response.dailyRequests)
    }

    /// Create a game request for a live game.
    /// - returns: A game id if the request was accepted by another user or bot.
    /// - note: If no other player accepts the live game request within 30 seconds, this request throws.
    public func requestLiveGame(
        allowBots: Bool,
        isRated: Bool,
        ratingRange: GameRatingRange,
        duration: LiveGameDuration,
        timeIncrement: LiveGameTimeIncrement
    ) async throws -> Int {
        try await sessionManager.checkSessionValidity()
        let params = OnlineLiveGameRequestParameters(
            allowBots: allowBots,
            timeout: 30000,
            isRated: isRated,
            infiniteTime: false,
            time: duration.time,
            timeIncrement: timeIncrement.increment,
            range: ratingRange.range
        )
        let response: OnlineGameIdResponse = try await apiClient.sendRequest(to: .createLiveGameRequest, parameters: params)
        return response.gameId
    }

    /// Accept a game request for a given live game request id.
    /// - returns: A game id if the request was successfully accepted.
    public func acceptLiveGameRequest(id: Int) async throws -> Int {
        try await sessionManager.checkSessionValidity()
        let response: OnlineGameIdResponse = try await apiClient.sendRequest(to: .acceptLiveGameRequest(id: id))
        return response.gameId
    }

    // MARK: - Daily Games

    /// Create a game request for a daily game.
    /// - returns: A game id if the request was accepted by another user.
    public func requestDailyGame(
        isRated: Bool,
        ratingRange: GameRatingRange,
        moveDuration: DailyGameMoveDuration
    ) async throws -> CreateOnlineDailyGameResponse {
        try await sessionManager.checkSessionValidity()
        let params = OnlineDailyGameRequestParameters(isRated: isRated, time: moveDuration.time, range: ratingRange.range)
        return try await apiClient.sendRequest(to: .createDailyGameRequest, parameters: params)
    }

    /// Accepts a daily game request created by another user.
    /// - returns: A game id if the request was successfully accepted.
    public func acceptDailyGameRequest(id: Int) async throws -> Int {
        try await sessionManager.checkSessionValidity()
        let response: OnlineGameIdResponse = try await apiClient.sendRequest(to: .acceptDailyGameRequest(id: id))
        return response.gameId
    }

    /// Cancels a daily game request created by the logged in user.
    public func cancelDailyGameRequest(id: Int) async throws {
        try await sessionManager.checkSessionValidity()
        try await apiClient.sendRequest(to: .cancelDailyGameRequest(id: id))
    }
}
