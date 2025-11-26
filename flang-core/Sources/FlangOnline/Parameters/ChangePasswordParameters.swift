import Foundation

struct ChangePasswordParameters: Codable {
    let currentPwdHash: String
    let newPwdHash: String
}
