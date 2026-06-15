//
//  RickAndMortyEndpoints.swift
//  RickAndMortyApp
//
//  Endpoints specific to Rick and Morty API.
//

import Foundation

// MARK: - Rick and Morty Endpoints

enum RickAndMortyEndpoint: EndpointProtocol {
    typealias Configuration = RickAndMortyAPIConfiguration
    
    // Character endpoints
    case characters(page: Int)
    case character(id: Int)
    case charactersByIDs(ids: [Int])
    case filterCharacters(name: String?, status: String?, species: String?, gender: String?, page: Int?)
    
    // Location endpoints
    case locations(page: Int)
    case location(id: Int)
    
    // Episode endpoints
    case episodes(page: Int)
    case episode(id: Int)
    
    // Raw URL (for pagination)
    case rawURL(URL)
    
    // MARK: - Path
    
    var path: String {
        switch self {
        case .characters, .filterCharacters:
            return "/character"
        case .character(let id):
            return "/character/\(id)"
        case .charactersByIDs(let ids):
            return "/character/\(ids.map(String.init).joined(separator: ","))"
        case .locations:
            return "/location"
        case .location(let id):
            return "/location/\(id)"
        case .episodes:
            return "/episode"
        case .episode(let id):
            return "/episode/\(id)"
        case .rawURL:
            return ""
        }
    }
    
    // MARK: - Query Items
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .characters(let page):
            return [URLQueryItem(name: "page", value: String(page))]
            
        case .locations(let page), .episodes(let page):
            return [URLQueryItem(name: "page", value: String(page))]
            
        case .filterCharacters(let name, let status, let species, let gender, let page):
            var items: [URLQueryItem] = []
            if let name = name { items.append(URLQueryItem(name: "name", value: name)) }
            if let status = status { items.append(URLQueryItem(name: "status", value: status)) }
            if let species = species { items.append(URLQueryItem(name: "species", value: species)) }
            if let gender = gender { items.append(URLQueryItem(name: "gender", value: gender)) }
            if let page = page { items.append(URLQueryItem(name: "page", value: String(page))) }
            return items.isEmpty ? nil : items
            
        default:
            return nil
        }
    }
    
    // MARK: - Build Request (Override for rawURL)
    
    func buildRequest(with configuration: RickAndMortyAPIConfiguration) throws -> URLRequest {
        switch self {
        case .rawURL(let url):
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.get.rawValue
            request.timeoutInterval = configuration.timeoutInterval
            configuration.defaultHeaders.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
            return request
            
        default:
            // Use default implementation
            var urlComponents = URLComponents(
                url: configuration.fullBaseURL.appendingPathComponent(path),
                resolvingAgainstBaseURL: true
            )
            urlComponents?.queryItems = queryItems
            
            guard let url = urlComponents?.url else {
                throw NetworkError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.timeoutInterval = configuration.timeoutInterval
            request.cachePolicy = configuration.cachePolicy
            
            configuration.defaultHeaders.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            return request
        }
    }
}
