import Foundation

public struct DailyStat: Codable {
    public let id: Int
    public let date: Int
    public let avgRating: Double
    public let activePlayersLastDay: Int
    public let gamesLastDay: Int
    public let solvedPuzzles: Int
    public let totalPuzzles: Int
}
