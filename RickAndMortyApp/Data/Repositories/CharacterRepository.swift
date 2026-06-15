//
//  CharacterRepository.swift
//  RickAndMortyApp
//
//  Repository implementation for character data operations.
//  Combines network and cache data sources.
//

import Foundation
import CoreData

// MARK: - Implementation

final class CharacterRepository: CharacterRepositoryProtocol {
    
    // MARK: - Properties
    
    private let apiClient: APIClientProtocol
    private let coreDataStack: CoreDataStack
    private var globalSortIndex: Int64 = 0
    
    // MARK: - Initialization
    
    init(apiClient: APIClientProtocol, coreDataStack: CoreDataStack) {
        self.apiClient = apiClient
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Fetch Characters
    
    func fetchCharacters(page: Int, nextURL: URL?) async throws -> PaginatedCharacters {
        let endpoint: RickAndMortyEndpoint
        if let nextURL = nextURL {
            endpoint = .rawURL(nextURL)
        } else {
            endpoint = .characters(page: page)
        }
        
        let response: CharacterListResponseDTO = try await apiClient.request(endpoint)
        return response.toDomain()
    }
    
    // MARK: - Cache Operations
    
    func cacheCharacters(_ characters: [CharacterEntity], page: Int) {
        let context = coreDataStack.viewContext
        
        context.perform { [weak self] in
            guard let self = self else { return }
            
            for character in characters {
                // Check if character already exists
                let fetchRequest: NSFetchRequest<CachedCharacter> = NSFetchRequest(entityName: "CachedCharacter")
                fetchRequest.predicate = NSPredicate(format: "id == %d", character.id)
                
                let existing = try? context.fetch(fetchRequest).first
                let entity: CachedCharacter
                
                if let existing = existing {
                    entity = existing
                } else {
                    entity = CachedCharacter(
                        entity: NSEntityDescription.entity(forEntityName: "CachedCharacter", in: context)!,
                        insertInto: context
                    )
                    self.globalSortIndex += 1
                }
                
                entity.update(from: character, page: page, sortIndex: self.globalSortIndex)
            }
            
            self.coreDataStack.save()
        }
    }
    
    func loadCachedCharacters() -> [CharacterEntity] {
        let context = coreDataStack.viewContext
        let fetchRequest: NSFetchRequest<CachedCharacter> = NSFetchRequest(entityName: "CachedCharacter")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sortIndex", ascending: true)]
        
        do {
            let cached = try context.fetch(fetchRequest)
            return cached.map { $0.toDomain() }
        } catch {
            return []
        }
    }
    
    func clearCache() {
        let context = coreDataStack.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedCharacter")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            coreDataStack.save()
            globalSortIndex = 0
        } catch {
            assertionFailure("Failed to clear cache: \(error)")
        }
    }
}
