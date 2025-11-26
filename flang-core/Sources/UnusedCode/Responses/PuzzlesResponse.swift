import Foundation

struct PuzzlesResponse: Codable {
    let puzzles: [Puzzle]
    let me: UserInfo
}
