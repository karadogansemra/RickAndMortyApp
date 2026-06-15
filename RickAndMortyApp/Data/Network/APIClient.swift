//
//  APIClient.swift
//  RickAndMortyApp
//
//  Backward-compatible API client using new network architecture.
//  This provides the old interface while using the new modular system.
//

import Foundation
import Alamofire

// MARK: - Protocol (Backward Compatible)

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: RickAndMortyEndpoint) async throws -> T
}

// MARK: - Implementation

final class APIClient: APIClientProtocol {
    
    // MARK: - Properties
    
    private let networkClient: RickAndMortyClient
    
    // MARK: - Singleton
    
    static let shared = APIClient()
    
    // MARK: - Initialization
    
    init(
        configuration: RickAndMortyAPIConfiguration = RickAndMortyAPIConfiguration(),
        session: Session = .default
    ) {
        self.networkClient = NetworkClient(
            configuration: configuration,
            session: session
        )
    }
    
    // MARK: - Request
    
    func request<T: Decodable>(_ endpoint: RickAndMortyEndpoint) async throws -> T {
        try await networkClient.request(endpoint)
    }
}

// MARK: - Simple URL Fetcher

/// Simple URL fetcher - use this when adding a new API.
/// Just provide a base URL from xcconfig, add path, and fetch.
final class SimpleAPIClient {
    
    static let shared = SimpleAPIClient()
    
    private let session: Session
    private let decoder: JSONDecoder
    
    init(session: Session = .default) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    /// Herhangi bir URL'den JSON decode et.
    /// Usage: let images: [PicsumImage] = try await SimpleAPIClient.shared.fetch(from: AppConfiguration.API.picsumBaseURL, path: "/list", query: ["page": "1"])
    func fetch<T: Decodable>(
        from baseURL: URL,
        path: String = "",
        query: [String: String]? = nil
    ) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        components?.queryItems = query?.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url)
                .validate()
                .responseDecodable(of: T.self, decoder: decoder) { response in
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        if let urlError = error.underlyingError as? URLError,
                           urlError.code == .notConnectedToInternet {
                            continuation.resume(throwing: NetworkError.noConnection)
                        } else if response.response?.statusCode == 429 {
                            continuation.resume(throwing: NetworkError.rateLimited)
                        } else {
                            continuation.resume(throwing: NetworkError.serverError(statusCode: response.response?.statusCode ?? 0))
                        }
                    }
                }
        }
    }
    
    /// Creates an image URL (for APIs that support URL-based resizing like Picsum)
    static func imageURL(baseURL: URL, width: Int, height: Int) -> URL? {
        baseURL.appendingPathComponent("\(width)/\(height)")
    }
}
