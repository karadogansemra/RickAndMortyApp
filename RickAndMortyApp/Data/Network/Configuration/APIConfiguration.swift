//
//  APIConfiguration.swift
//  RickAndMortyApp
//
//  Protocol-based API configuration for multi-tenant support.
//  Reads base URLs and settings from xcconfig via AppConfiguration.
//

import Foundation

// MARK: - API Configuration Protocol

protocol APIConfiguration {
    /// Base URL for the API
    var baseURL: URL { get }
    
    /// API version (e.g., "v1", "v2")
    var apiVersion: String? { get }
    
    /// Default headers for all requests
    var defaultHeaders: [String: String] { get }
    
    /// Request timeout interval
    var timeoutInterval: TimeInterval { get }
    
    /// Cache policy
    var cachePolicy: URLRequest.CachePolicy { get }
}

// MARK: - Default Implementation

extension APIConfiguration {
    var apiVersion: String? { nil }
    
    var defaultHeaders: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    var timeoutInterval: TimeInterval {
        AppConfiguration.API.timeout
    }
    
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
    
    /// Full base URL including API version
    var fullBaseURL: URL {
        if let version = apiVersion {
            return baseURL.appendingPathComponent(version)
        }
        return baseURL
    }
}

// MARK: - Rick and Morty API Configuration

struct RickAndMortyAPIConfiguration: APIConfiguration {
    
    // Uses URL from xcconfig
    var baseURL: URL {
        AppConfiguration.API.rickAndMortyBaseURL
    }
    
    var apiVersion: String? { nil }
    
    var defaultHeaders: [String: String] {
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-App-Version": AppConfiguration.fullVersion,
            "X-Platform": "iOS",
            "X-Environment": AppConfiguration.environment.rawValue
        ]
        
        // Add debug headers in non-production
        if !AppConfiguration.environment.isProduction {
            headers["X-Debug"] = "true"
        }
        
        return headers
    }
    
    var timeoutInterval: TimeInterval {
        AppConfiguration.API.timeout
    }
}

// MARK: - Example: Configurable API

/// Example configuration that reads from xcconfig
struct ConfigurableAPIConfiguration: APIConfiguration {
    
    let baseURL: URL
    let apiVersion: String?
    let apiKey: String?
    
    init(
        baseURL: URL = AppConfiguration.API.exampleAPIBaseURL ?? URL(string: "https://api.example.com")!,
        apiVersion: String? = AppConfiguration.API.version,
        apiKey: String? = nil
    ) {
        self.baseURL = baseURL
        self.apiVersion = apiVersion
        self.apiKey = apiKey
    }
    
    var defaultHeaders: [String: String] {
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-App-Version": AppConfiguration.fullVersion
        ]
        
        if let apiKey = apiKey {
            headers["Authorization"] = "Bearer \(apiKey)"
        }
        
        return headers
    }
}

// MARK: - Bundle Extension

extension Bundle {
    var appVersion: String {
        AppConfiguration.version
    }
    
    var buildNumber: String {
        AppConfiguration.buildNumber
    }
}
