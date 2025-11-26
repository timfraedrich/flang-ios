import Foundation

public struct ChatAttachedGame: Codable {
    public let id: String?
    public let fmn: String?
    public let fbn: String?
    
    public init(id: String?, fmn: String?, fbn: String?) {
        self.id = id
        self.fmn = fmn
        self.fbn = fbn
    }
}
