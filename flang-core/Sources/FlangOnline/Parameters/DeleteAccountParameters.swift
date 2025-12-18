import Foundation

struct DeleteAccountParameters: Codable {
    let username: String
    let passwordHash: String
}
