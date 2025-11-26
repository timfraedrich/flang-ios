import Foundation

public struct ChatMessage: Codable {
    public let sender: ChatUser
    public let date: Int
    public let text: String
    public let game: ChatAttachedGame?
    
    public init(sender: ChatUser, date: Int, text: String, game: ChatAttachedGame?) {
        self.sender = sender
        self.date = date
        self.text = text
        self.game = game
    }
}
