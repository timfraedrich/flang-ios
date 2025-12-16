import Foundation
import Observation

@MainActor
@Observable
public class CommunityService {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    /// Get user information
    public func getUserProfile(username: String) async throws -> PlayerProfile {
        try await apiClient.sendRequest(to: .getUserProfile(username: username))
    }

    /// Get user's games
    public func getUserGames(username: String, max: Int? = nil, offset: Int? = nil) async throws -> [OnlineGameInfo] {
        let response: GamesResponse = try await apiClient.sendRequest(to: .getUserGames(username: username, max: max, offset: offset))
        return response.games
    }

    /// Search for users
    public func searchUsers(username: String) async throws -> [UserInfo] {
        let response: UserInfosResponse = try await apiClient.sendRequest(to: .searchUsers(username: username))
        return response.users
    }

    /// Get top players for bullet, blitz, classical or daily. Other rating types might result in an error.
    public func getTopPlayers(for type: RatingType) async throws -> [UserInfo] {
        let parameters = GetTopPlayersParameters(type: type)
        let response: UserInfosResponse = try await apiClient.sendRequest(to: .getTopPlayers, parameters: parameters)
        return response.users
    }

    /// Get online players
    public func getOnlinePlayers() async throws -> [UserInfo] {
        let response: UserInfosResponse = try await apiClient.sendRequest(to: .getOnlinePlayers)
        return response.users
    }
}
