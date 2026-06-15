//
//  FetchCharactersUseCase.swift
//  RickAndMortyApp
//
//  Use case for fetching characters with pagination support.
//  Handles business logic for character list retrieval including offline fallback.
//

import Foundation

// MARK: - Protocol

protocol FetchCharactersUseCaseProtocol {
    /// Fetches the next page of characters.
    /// - Parameters:
    ///   - page: Page number to fetch
    ///   - nextURL: Optional pagination URL from previous response
    /// - Returns: Paginated characters
    func execute(page: Int, nextURL: URL?) async throws -> PaginatedCharacters
    
    /// Loads cached characters for offline support.
    /// - Returns: Cached characters if available
    func loadCachedCharacters() -> [CharacterEntity]
}

// MARK: - Implementation

final class FetchCharactersUseCase: FetchCharactersUseCaseProtocol {
    
    // MARK: - Properties
    
    private let repository: CharacterRepositoryProtocol
    
    // MARK: - Initialization
    
    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execution
    
    func execute(page: Int, nextURL: URL?) async throws -> PaginatedCharacters {
        let result = try await repository.fetchCharacters(page: page, nextURL: nextURL)
        
        // Cache the fetched characters for offline support
        repository.cacheCharacters(result.characters, page: page)
        
        return result
    }
    
    func loadCachedCharacters() -> [CharacterEntity] {
        repository.loadCachedCharacters()
    }
}
