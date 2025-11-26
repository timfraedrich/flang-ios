import Foundation
import Observation

@MainActor
@Observable
public class FlangOnline {
    
    nonisolated static let defaultAPIURL = "https://www.tadris.de/api/flang"
    nonisolated static let moduleIdentifier: String = "de.tadris.flang-core.flang-online"
    
    public let sessionManager: SessionManager
    public let onlineGameService: OnlineGameService
    public let communityService: CommunityService
    
    public init() throws {
        guard let baseURL = URL(string: Self.defaultAPIURL) else { throw Error.invalidBaseURL }
        let apiClient = APIClient(baseURL: baseURL)
        self.sessionManager = SessionManager(apiClient: apiClient)
        self.onlineGameService = OnlineGameService(apiClient: apiClient)
        self.communityService = CommunityService(apiClient: apiClient)
    }
    
    public enum Error: Swift.Error {
        case invalidBaseURL
    }
}
