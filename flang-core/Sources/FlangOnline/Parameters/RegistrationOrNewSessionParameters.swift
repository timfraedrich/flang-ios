import Foundation

typealias RegistrationParameters = RegistrationOrNewSessionParameters
typealias NewSessionParameters = RegistrationParameters
struct RegistrationOrNewSessionParameters: Codable {
    let username: String
    let pwdHash: String
}
