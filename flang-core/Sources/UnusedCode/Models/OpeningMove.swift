import Foundation

public struct OpeningMove: Codable {
    public let move: String
    public let gameCount: Int
    public let winCount: Int
    public let looseCount: Int
}
