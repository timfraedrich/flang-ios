import Foundation

public struct OnlineLiveGameRequest: Codable, Sendable {
    public let id: Int
    public let configuration: OnlineGameConfiguration
    public let requester: UserInfo
    
    public init(id: Int, configuration: OnlineGameConfiguration, requester: UserInfo) {
        self.id = id
        self.configuration = configuration
        self.requester = requester
    }
}
