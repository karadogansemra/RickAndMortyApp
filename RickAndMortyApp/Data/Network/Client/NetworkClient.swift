//
//  NetworkClient.swift
//  RickAndMortyApp
//
//  Generic, reusable network client that works with any API configuration.
//  Protocol-based for easy testing and mocking.
//

import Foundation
import Alamofire

// MARK: - Network Client Protocol

protocol NetworkClientProtocol {
    associatedtype Configuration: APIConfiguration
    
    var configuration: Configuration { get }
    
    /// Performs a network request and decodes the response.
    func request<T: Decodable, E: EndpointProtocol>(
        _ endpoint: E
    ) async throws -> T where E.Configuration == Configuration
    
    /// Performs a network request without expecting a response body.
    func requestVoid<E: EndpointProtocol>(
        _ endpoint: E
    ) async throws where E.Configuration == Configuration
}

// MARK: - Network Client Implementation

final class NetworkClient<Config: APIConfiguration>: NetworkClientProtocol {
    typealias Configuration = Config
    
    // MARK: - Properties
    
    let configuration: Config
    private let session: Session
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    init(
        configuration: Config,
        session: Session = .default,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.configuration = configuration
        self.session = session
        self.decoder = decoder
    }
    
    // MARK: - Request
    
    func request<T: Decodable, E: EndpointProtocol>(
        _ endpoint: E
    ) async throws -> T where E.Configuration == Config {
        let urlRequest = try endpoint.buildRequest(with: configuration)
        
        logRequest(urlRequest)
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(urlRequest)
                .validate()
                .responseDecodable(of: T.self, decoder: decoder) { [weak self] response in
                    guard let self = self else { return }
                    
                    self.logResponse(response.response, data: response.data, error: response.error)
                    
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                        
                    case .failure(let error):
                        let networkError = self.mapError(error, response: response.response)
                        continuation.resume(throwing: networkError)
                    }
                }
        }
    }
    
    func requestVoid<E: EndpointProtocol>(
        _ endpoint: E
    ) async throws where E.Configuration == Config {
        let urlRequest = try endpoint.buildRequest(with: configuration)
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(urlRequest)
                .validate()
                .response { [weak self] response in
                    guard let self = self else { return }
                    
                    if let error = response.error {
                        let networkError = self.mapError(error, response: response.response)
                        continuation.resume(throwing: networkError)
                    } else {
                        continuation.resume()
                    }
                }
        }
    }
    
    // MARK: - Error Mapping
    
    private func mapError(_ error: AFError, response: HTTPURLResponse?) -> NetworkError {
        // Check for no connection
        if let underlying = error.underlyingError as? URLError {
            switch underlying.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .noConnection
            case .timedOut:
                return .timeout
            default:
                break
            }
        }
        
        // Check for server errors
        if let statusCode = response?.statusCode {
            switch statusCode {
            case 401:
                return .unauthorized
            case 403:
                return .forbidden
            case 404:
                return .notFound
            case 429:
                return .rateLimited
            case 500...599:
                return .serverError(statusCode: statusCode)
            default:
                if !(200...299).contains(statusCode) {
                    return .serverError(statusCode: statusCode)
                }
            }
        }
        
        // Check for decoding errors
        if case .responseSerializationFailed(let reason) = error,
           case .decodingFailed(let decodingError) = reason {
            return .decodingFailed(decodingError)
        }
        
        // Underlying error
        if let underlying = error.underlyingError {
            return .underlying(underlying)
        }
        
        return .unknown
    }
    
    // MARK: - Logging
    
    private func logRequest(_ request: URLRequest) {
        #if DEBUG
        guard AppConfiguration.Features.isLoggingEnabled else { return }
        
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "nil"
        
        print("📡 [\(method)] \(url)")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("   Headers: \(headers)")
        }
        
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("   Body: \(bodyString)")
        }
        #endif
    }
    
    private func logResponse(_ response: HTTPURLResponse?, data: Data?, error: AFError?) {
        #if DEBUG
        guard AppConfiguration.Features.isLoggingEnabled else { return }
        
        let statusCode = response?.statusCode ?? 0
        let url = response?.url?.absoluteString ?? "nil"
        let icon = (200...299).contains(statusCode) ? "✅" : "❌"
        
        print("\(icon) [\(statusCode)] \(url)")
        
        if let data = data {
            print("   Size: \(data.count) bytes")
        }
        
        if let error = error {
            print("   Error: \(error.localizedDescription)")
        }
        #endif
    }
}

// MARK: - Convenience Type Aliases

/// Pre-configured client for Rick and Morty API
typealias RickAndMortyClient = NetworkClient<RickAndMortyAPIConfiguration>
