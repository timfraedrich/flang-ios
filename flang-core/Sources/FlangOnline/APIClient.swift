import Combine
import Foundation

final class APIClient: Sendable {
    
    let baseURL: URL
    let urlSession: URLSession
    
    init(baseURL: URL) {
        self.baseURL = baseURL
        let config = URLSessionConfiguration.default
        config.httpCookieAcceptPolicy = .always
        config.httpCookieStorage = .shared
        urlSession = URLSession(configuration: config)
    }

    // MARK: - Public API

    /// Send request with no parameters and no response content
    func sendRequest(to endpoint: APIEndpoint) async throws {
        let request = try urlRequest(to: endpoint)
        try await dataTask(for: request)
    }

    /// Send request with parameters but no response (e.g., POST with 204 No Content)
    func sendRequest<Parameters: Encodable>(to endpoint: APIEndpoint, parameters: Parameters) async throws {
        let request = try urlRequest(to: endpoint, encoding: parameters)
        try await dataTask(for: request)
    }

    /// Send request with no parameters and decode response
    func sendRequest<Response: Decodable>(to endpoint: APIEndpoint) async throws -> Response {
        let request = try urlRequest(to: endpoint)
        return try await dataTask(for: request)
    }

    /// Send request with parameters and decode response
    func sendRequest<Parameters: Encodable, Response: Decodable>(to endpoint: APIEndpoint, parameters: Parameters) async throws -> Response {
        let request = try urlRequest(to: endpoint, encoding: parameters)
        return try await dataTask(for: request)
    }

    // MARK: - Request Building

    private func urlRequest<Parameters: Encodable>(to endpoint: APIEndpoint, encoding parameters: Parameters) throws -> URLRequest {
        guard let baseUrl = endpoint.url(for: baseURL)?.absoluteString else { throw APIError.invalidURL }
        guard let url = paramUrl(with: baseUrl, and: parameters) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }

    private func urlRequest(to endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = endpoint.url(for: baseURL) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }

    private func paramUrl(with url: String, and params: Encodable) -> URL? {
        guard var components = URLComponents(string: url), let params = try? params.asDictionary() else { return nil }
        var queryItems = components.queryItems ?? []
        queryItems.append(contentsOf: params.map { key, value in
            if let value = value as? Encodable, let data = try? JSONEncoder().encode(value) {
                URLQueryItem(name: key, value: .init(data: data, encoding: .utf8))
            } else {
                URLQueryItem(name: key, value: .init(describing: value))
            }
        })
        components.queryItems = queryItems
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return components.url
    }

    // MARK: - Data Tasks

    private func dataTask<Response: Decodable>(for request: URLRequest) async throws -> Response {
        let data = try await dataTask(for: request)
        return try JSONDecoder().decode(Response.self, from: data)
    }

    @discardableResult
    private func dataTask(for request: URLRequest) async throws -> Data {
        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.operationFailed(errorCode: httpResponse.statusCode, data: data)
        }

        return data
    }
}
