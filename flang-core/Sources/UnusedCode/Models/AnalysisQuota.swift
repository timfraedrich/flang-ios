import Foundation

public struct AnalysisQuota: Codable {
    public let dailyLimit: Int
    public let used: Int
    public let remaining: Int
    
    public init(dailyLimit: Int, used: Int, remaining: Int) {
        self.dailyLimit = dailyLimit
        self.used = used
        self.remaining = remaining
    }
}
