import Foundation

public struct ChatUser: Codable {
    public let username: String
    public let title: String?
    public let rating: Double
    public let isBot: Bool
}
