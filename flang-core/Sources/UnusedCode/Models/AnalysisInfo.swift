import Foundation

public struct AnalysisInfo: Codable {
    public let id: Int
    public let fmn: String
    public let dateStarted: Int
    public let dateEnded: Int?
    public let isFinished: Bool
    public let progress: Double
    public let data: String?
    
    public init(id: Int, fmn: String, dateStarted: Int, dateEnded: Int?, isFinished: Bool, progress: Double, data: String?) {
        self.id = id
        self.fmn = fmn
        self.dateStarted = dateStarted
        self.dateEnded = dateEnded
        self.isFinished = isFinished
        self.progress = progress
        self.data = data
    }
}
