import CryptoKit
import Foundation
import Observation
import OSLog

@MainActor
@Observable
public class SessionManager {
    
    private let logger = Logger(category: "SessionManager")
    private let cryptoStore = CryptoStore()
    private let apiClient: APIClient
    
    public private(set) var status: Status
    public var username: String? { status.username }
    public var isLoggedIn: Bool { if case .loggedIn = status { true } else { false } }
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
        do {
            if let username = try cryptoStore.readKey(account: "username"), let key = try cryptoStore.readKey(account: "sessionKey") {
                status = .tryingToRestoreSession(username: username)
                tryToRestoreSession(username: username, sessionKey: key)
            } else {
                status = .loggedOut
            }
        } catch {
            logger.warning("Failed to read session from keychain: \(error)")
            status = .loggedOut
        }
    }
    
    // MARK: - Authentication
    
    /// Register a new user
    public func register(username: String, password: String) async throws {
        let pwdHash = Self.hashPassword(password)
        let params = RegistrationParameters(username: username, pwdHash: pwdHash)
        try await apiClient.sendRequest(to: .register, parameters: params)
    }
    
    /// Login with username and password
    public func login(username: String, password: String) async throws {
        let newSessionParams = NewSessionParameters(username: username, pwdHash: Self.hashPassword(password))
        let newSessionResponse: SessionResponse = try await apiClient.sendRequest(to: .newSession, parameters: newSessionParams)
        // Now login with the session key (this sets the cookie)
        let loginParams = LoginParameters(username: username, key: newSessionResponse.key)
        try await apiClient.sendRequest(to: .login, parameters: loginParams)
        try saveSession(username: username, sessionKey: loginParams.key)
        status = .loggedIn(username: username, sessionKey: password)
    }
    
    /// Logout and clear session
    public func logout() throws {
        try clearSession()
        status = .loggedOut
    }
    
    /// Change password
    public func changePassword(currentPassword: String, newPassword: String) async throws {
        guard case let .loggedIn(username, _) = status else { throw Error.notLoggedIn }
        let currentPwdHash = Self.hashPassword(currentPassword)
        let newPwdHash = Self.hashPassword(newPassword)
        let params = ChangePasswordParameters(currentPwdHash: currentPwdHash, newPwdHash: newPwdHash)
        try await apiClient.sendRequest(to: .changePassword, parameters: params)
        // After password change, all other sessions are deleted
        // We need to create a new session
        try await login(username: username, password: newPassword)
    }
    
    // MARK: - Session Persistence
    
    private func tryToRestoreSession(username: String, sessionKey: String) {
        Task {
            let status: Status
            do {
                let loginParams = LoginParameters(username: username, key: sessionKey)
                try await apiClient.sendRequest(to: .login, parameters: loginParams)
                try clearSession()
                try saveSession(username: username, sessionKey: sessionKey)
                status = .loggedIn(username: username, sessionKey: sessionKey)
            } catch {
                try? clearSession()
                status = .loggedOut
                logger.error("Failed to restore session: \(error)")
            }
            await MainActor.run { self.status = status }
        }
    }
    
    private func saveSession(username: String, sessionKey: String) throws {
        try cryptoStore.storeKey(key: username, account: "username")
        try cryptoStore.storeKey(key: sessionKey, account: "sessionKey")
    }

    private func clearSession() throws {
        try cryptoStore.deleteKey(account: "username")
        try cryptoStore.deleteKey(account: "sessionKey")
    }
    
    // MARK: Types
    
    public enum Status: Hashable, Sendable {
        
        case loggedOut
        case loggedIn(username: String, sessionKey: String)
        case tryingToRestoreSession(username: String)
        
        public var username: String? {
            switch self {
            case .loggedIn(let username, _), .tryingToRestoreSession(let username): username
            default: nil
            }
        }
        
        public var sessionKey: String? {
            switch self {
            case .loggedIn(_, let sessionKey): sessionKey
            default: nil
            }
        }
    }
    
    // TODO: Localize
    public enum Error: Swift.Error {
        case notLoggedIn
    }
    
    // MARK: Helper
    
    private static func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
