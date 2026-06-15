//
//  NetworkError.swift
//  RickAndMortyApp
//
//  Network layer error types.
//

import Foundation

// MARK: - Network Error

enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case noConnection
    case timeout
    case unauthorized
    case forbidden
    case notFound
    case rateLimited          
    case decodingFailed(Error)
    case serverError(statusCode: Int)
    case underlying(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return L10n.Error.invalidURL
        case .noConnection:
            return L10n.Error.noConnection
        case .timeout:
            return "error.timeout".localized
        case .unauthorized:
            return "error.unauthorized".localized
        case .forbidden:
            return "error.forbidden".localized
        case .notFound:
            return "error.notFound".localized
        case .rateLimited:
            return "error.rateLimited".localized
        case .decodingFailed:
            return L10n.Error.decodingFailed
        case .serverError(let code):
            return L10n.Error.serverError(code)
        case .underlying(let error):
            return error.localizedDescription
        case .unknown:
            return L10n.Error.unknown
        }
    }
    
    var isOfflineError: Bool {
        if case .noConnection = self { return true }
        return false
    }
    
    var isAuthError: Bool {
        switch self {
        case .unauthorized, .forbidden:
            return true
        default:
            return false
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .rateLimited, .timeout, .serverError:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Equatable
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noConnection, .noConnection),
             (.timeout, .timeout),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.rateLimited, .rateLimited),
             (.unknown, .unknown):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        case (.decodingFailed, .decodingFailed),
             (.underlying, .underlying):
            return true
        default:
            return false
        }
    }
}
