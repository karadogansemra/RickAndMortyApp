//
//  CharacterRepositoryProtocol.swift
//  RickAndMortyApp
//
//  Repository protocol for character data operations.
//  Abstracts the data source (network, cache, etc.) from the domain layer.
//

import Foundation

// MARK: - Character Repository Protocol

protocol CharacterRepositoryProtocol {
    /// Fetches a page of characters from the API.
    /// - Parameters:
    ///   - page: The page number to fetch (1-based)
    ///   - nextURL: Optional URL for pagination (overrides page if provided)
    /// - Returns: Paginated characters response
    func fetchCharacters(page: Int, nextURL: URL?) async throws -> PaginatedCharacters
    
    /// Saves characters to local cache for offline support.
    /// - Parameters:
    ///   - characters: Characters to cache
    ///   - page: The page number these characters belong to
    func cacheCharacters(_ characters: [CharacterEntity], page: Int)
    
    /// Loads all cached characters from local storage.
    /// - Returns: Array of cached characters, sorted by original API order
    func loadCachedCharacters() -> [CharacterEntity]
    
    /// Clears all cached characters.
    func clearCache()
}

// MARK: - Default Implementation

extension CharacterRepositoryProtocol {
    func fetchCharacters(page: Int) async throws -> PaginatedCharacters {
        try await fetchCharacters(page: page, nextURL: nil)
    }
}
