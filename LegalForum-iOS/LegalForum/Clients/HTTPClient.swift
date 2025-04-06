//
//  HTTPClient.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//


import Foundation

struct Resource<T: Codable> {
    var url: URL
    var method: HTTPMethod = .POST
    var modelType: T.Type
    var headers: [String: String]?
    var body: Data?
}

/// HTTP Methods
enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

/// HTTP Errors
enum HTTPError: Error {
    case invalidResponse(statusCode: Int)
    case decodingFailed(error: Error)
    case errorResponse(ErrorResponse)
    case invalidToken
    case noData
}

struct HTTPClient {
    let urlSession: URLSession
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    /// Makes an HTTP request and decodes the response into a generic type.
    /// - Parameters:
    ///   - url: The URL to make the request to.
    ///   - method: The HTTP method (GET, POST, PUT, DELETE).
    ///   - headers: Optional headers for the request.
    ///   - body: Optional body for the request (for POST/PUT).
    /// - Returns: A decoded object of the specified type.
    func load<T: Decodable>(
        resource: Resource<T>
    ) async throws -> HTTPResponse<T> {
        var request = URLRequest(url: resource.url)
        request.httpMethod = resource.method.rawValue
        request.allHTTPHeaderFields = resource.headers
        request.httpBody = resource.body
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw HTTPError.invalidResponse(statusCode: statusCode)
        }
        
        switch httpResponse.statusCode {
        case (200..<300):
            break
        default:
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            throw HTTPError.errorResponse(errorResponse)
        }
        
        do {
            let decodedData = try JSONDecoder().decode(HTTPResponse<T>.self, from: data)
            return decodedData
        } catch {
            throw HTTPError.decodingFailed(error: error)
        }
    }
}

struct ErrorResponse: Codable {
    let message: String?
}

struct HTTPResponse<T: Codable>: Codable {
    let message: String?
    let data: T?
    let metadata: Metadata?
}

struct Metadata: Codable {
    let page: Int?
    let limit: Int?
    let total: Int?
}
