import Foundation

public enum APIError: Swift.Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case operationFailed(errorCode: Int, data: Data)

    // TODO: Add Localization
    public var errorDescription: String? {
        let base = "API request failed. "
        let reason: String
        switch self {
        case .invalidURL:
            reason = "The provided URL was invalid."
        case .invalidResponse:
            reason = "The server response was invalid."
        case .operationFailed(let errorCode, let data):
            var message = "HTTP \(errorCode)"
            if let errorMessage = String(data: data, encoding: .utf8), !errorMessage.isEmpty {
                message += ": \(errorMessage)"
            }
            reason = message
        }
        return base + reason
    }
}
