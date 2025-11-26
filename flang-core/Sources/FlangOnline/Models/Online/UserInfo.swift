import Foundation

public struct UserInfo: Codable, Sendable {
    public let username: String
    public let title: String?
    public let isBot: Bool
    public let rating: Double
    
    public init(username: String, title: String?, isBot: Bool, rating: Double) {
        self.username = username
        self.title = title
        self.isBot = isBot
        self.rating = rating
    }
}
