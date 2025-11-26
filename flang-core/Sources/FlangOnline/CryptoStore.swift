import Foundation
import CryptoKit
import Security

final class CryptoStore: Sendable {
    
    private static let service = FlangOnline.moduleIdentifier
    
    func storeKey(key: String, account: String) throws {
        guard let data = key.data(using: .utf8) else { throw CryptoStoreError("Unable to convert key to Data.") }
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account as CFString,
            kSecAttrService: Self.service as CFString,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
            kSecUseDataProtectionKeychain: true,
            kSecAttrSynchronizable: false,
            kSecValueData: data as CFData,
        ] as [String: Any]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw CryptoStoreError("Unable to store item: \(status.message)")
        }
    }
    
    func readKey(account: String) throws -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account as CFString,
            kSecAttrService: Self.service as CFString,
            kSecUseDataProtectionKeychain: true,
            kSecReturnData: true,
        ] as [String: Any]
        
        var item: CFTypeRef?
        switch SecItemCopyMatching(query as CFDictionary, &item) {
        case errSecSuccess:
            guard let data = item as? Data else { throw CryptoStoreError("Unexpected keychain item type: \(type(of: item)))") }
            return String(data: data, encoding: .utf8)
        case errSecItemNotFound:
            return nil
        case let status:
            throw CryptoStoreError("Keychain read failed: \(status.message)")
        }
    }
    
    func deleteKey(account: String) throws {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account as CFString,
            kSecAttrService: Self.service as CFString,
            kSecUseDataProtectionKeychain: true,
        ] as [String: Any]
        switch SecItemDelete(query as CFDictionary) {
        case errSecItemNotFound, errSecSuccess:
            break
        case let status:
            throw CryptoStoreError("Unexpected deletion error: \(status.message)")
        }
    }
    
    // MARK: Error Management
    
    struct CryptoStoreError: Error, CustomStringConvertible {
        var message: String
        
        init(_ message: String) {
            self.message = message
        }
        
        public var description: String {
            return message
        }
    }
}
