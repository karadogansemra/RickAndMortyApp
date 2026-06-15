//
//  EndpointProtocol.swift
//  RickAndMortyApp
//
//  Generic endpoint protocol for defining API endpoints.
//  Can be used with any API configuration.
//

import Foundation

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Endpoint Protocol

protocol EndpointProtocol {
    /// Associated API configuration type
    associatedtype Configuration: APIConfiguration
    
    /// Path component (e.g., "/character", "/users/123")
    var path: String { get }
    
    /// HTTP method
    var method: HTTPMethod { get }
    
    /// Query parameters
    var queryItems: [URLQueryItem]? { get }
    
    /// Request body (for POST, PUT, PATCH)
    var body: Data? { get }
    
    /// Additional headers specific to this endpoint
    var additionalHeaders: [String: String]? { get }
    
    /// Whether this endpoint requires authentication
    var requiresAuthentication: Bool { get }
    
    /// Build the full URL request
    func buildRequest(with configuration: Configuration) throws -> URLRequest
}

// MARK: - Default Implementation

extension EndpointProtocol {
    var method: HTTPMethod { .get }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
    var additionalHeaders: [String: String]? { nil }
    var requiresAuthentication: Bool { false }
    
    func buildRequest(with configuration: Configuration) throws -> URLRequest {
        // Build URL
        var urlComponents = URLComponents(url: configuration.fullBaseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = configuration.timeoutInterval
        request.cachePolicy = configuration.cachePolicy
        
        // Add default headers
        configuration.defaultHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add additional headers
        additionalHeaders?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
}

// MARK: - Raw URL Endpoint

/// Special endpoint for following pagination links or external URLs
struct RawURLEndpoint<Config: APIConfiguration>: EndpointProtocol {
    typealias Configuration = Config
    
    let url: URL
    
    var path: String { "" }
    
    func buildRequest(with configuration: Config) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.timeoutInterval = configuration.timeoutInterval
        
        configuration.defaultHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}
