import Foundation

public struct ServerAnnouncement: Codable {
    public let id: Int
    public let showUntil: Int
    public let title: String
    public let text: String
    public let url: String?
    public let priority: Int
}
