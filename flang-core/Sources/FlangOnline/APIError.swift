import Foundation

public enum APIError: Swift.Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case operationFailed(errorCode: Int, data: Data)
    
    public var errorDescription: String? {
        let base = String(localized: "api_error_base", bundle: .module)
        let reason: String
        switch self {
        case .invalidURL:
            reason = .init(localized: "api_error_invalid_url", bundle: .module)
        case .invalidResponse:
            reason = .init(localized: "api_error_invalid_response", bundle: .module)
        case .operationFailed(let errorCode, let data):
            var message: String = .init(localized: "api_error_http_\(errorCode)", bundle: .module)
            if let errorMessage = String(data: data, encoding: .utf8), !errorMessage.isEmpty {
                message += ": \(errorMessage)"
            }
            reason = message
        }
        return base + " " + reason
    }
}
