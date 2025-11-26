import Foundation

public struct ServerInfo: Codable {
    public let playerCount: Int
    public let gameCount: Int
    public let announcements: [ServerAnnouncement]
}
