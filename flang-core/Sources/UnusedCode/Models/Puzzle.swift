import Foundation

public struct Puzzle: Codable {
    public let id: Int
    public let startFMN: String
    public let puzzleFMN: String
    public let elo: Double
    public let views: Int
}
