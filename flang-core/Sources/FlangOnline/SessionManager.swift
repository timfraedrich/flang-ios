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
    
    public var lastAuthentication: Date?
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
    /// - note: This function does not log the user in.
    public func register(username: String, password: String) async throws {
        let pwdHash = Self.hashPassword(password)
        let params = RegistrationParameters(username: username, pwdHash: pwdHash)
        try await apiClient.sendRequest(to: .register, parameters: params)
    }
    
    /// Login with username and password
    public func login(username: String, password: String) async throws {
        let newSessionParams = NewSessionParameters(username: username, pwdHash: Self.hashPassword(password))
        let newSessionResponse: SessionResponse = try await apiClient.sendRequest(to: .newSession, parameters: newSessionParams)
        // login with the session key to set the cookie
        try await login(username: username, key: newSessionResponse.key)
    }
    
    /// Logout and clear session
    public func logout() throws {
        try clearSession()
        status = .loggedOut
        lastAuthentication = nil
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
    
    /// Checks if the current session is still valid and extends it if not.
    public func checkSessionValidity() async throws {
        guard case .loggedIn(let username, let sessionKey) = status else { throw Error.notLoggedIn }
        guard let lastAuthentication, lastAuthentication.distance(to: .now) > 15 * 60 else { return }
        try await login(username: username, key: sessionKey)
    }
    
    /// Login and sets cookie, valid for 30 minutes
    private func login(username: String, key: String) async throws {
        let now = Date.now
        let loginParams = LoginParameters(username: username, key: key)
        try await apiClient.sendRequest(to: .login, parameters: loginParams)
        try clearSession()
        try saveSession(username: username, sessionKey: key)
        status = .loggedIn(username: username, sessionKey: key)
        lastAuthentication = now
    }
    
    // MARK: - Session Persistence
    
    private func tryToRestoreSession(username: String, sessionKey: String) {
        Task {
            do {
                try await login(username: username, key: sessionKey)
            } catch {
                try? clearSession()
                status = .loggedOut
                logger.error("Failed to restore session: \(error)")
            }
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
