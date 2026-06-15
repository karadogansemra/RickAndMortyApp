//
//  DependencyContainer.swift
//  RickAndMortyApp
//
//  Dependency Injection Container - Manages all dependencies in the app.
//  Single source of truth for creating and providing dependencies.
//

import Foundation

/// Protocol for dependency injection container
protocol DependencyContainerProtocol {
    // MARK: - Network
    var apiClient: APIClientProtocol { get }
    
    // MARK: - Repositories
    var characterRepository: CharacterRepositoryProtocol { get }
    var photoLibraryRepository: PhotoLibraryRepositoryProtocol { get }
    
    // MARK: - Use Cases
    func makeFetchCharactersUseCase() -> FetchCharactersUseCaseProtocol
    func makeGalleryPhotosUseCase() -> GalleryPhotosUseCaseProtocol
    func makeSavePhotoUseCase() -> SavePhotoUseCaseProtocol
    
    // MARK: - ViewModels
    @MainActor func makeCharacterListViewModel() -> CharacterListViewModel
    func makeCharacterDetailViewModel(character: CharacterEntity) -> CharacterDetailViewModel
    func makePhotoDetailViewModel(characterName: String, imageURL: URL?) -> PhotoDetailViewModel
}

/// Concrete implementation of dependency container
final class DependencyContainer: DependencyContainerProtocol {
    
    // MARK: - Singleton
    
    static let shared = DependencyContainer()
    
    // MARK: - Core Dependencies
    
    private(set) lazy var coreDataStack: CoreDataStack = {
        CoreDataStack()
    }()
    
    // MARK: - Network
    
    private(set) lazy var apiClient: APIClientProtocol = {
        APIClient()
    }()
    
    // MARK: - Repositories
    
    private(set) lazy var characterRepository: CharacterRepositoryProtocol = {
        CharacterRepository(
            apiClient: apiClient,
            coreDataStack: coreDataStack
        )
    }()
    
    private(set) lazy var photoLibraryRepository: PhotoLibraryRepositoryProtocol = {
        PhotoLibraryRepository()
    }()
    
    // MARK: - Use Cases
    
    func makeFetchCharactersUseCase() -> FetchCharactersUseCaseProtocol {
        FetchCharactersUseCase(repository: characterRepository)
    }
    
    func makeGalleryPhotosUseCase() -> GalleryPhotosUseCaseProtocol {
        GalleryPhotosUseCase(repository: photoLibraryRepository)
    }
    
    func makeSavePhotoUseCase() -> SavePhotoUseCaseProtocol {
        SavePhotoUseCase(repository: photoLibraryRepository)
    }
    
    // MARK: - ViewModels
    
    @MainActor
    func makeCharacterListViewModel() -> CharacterListViewModel {
        CharacterListViewModel(
            fetchCharactersUseCase: makeFetchCharactersUseCase(),
            galleryPhotosUseCase: makeGalleryPhotosUseCase()
        )
    }
    
    func makeCharacterDetailViewModel(character: CharacterEntity) -> CharacterDetailViewModel {
        CharacterDetailViewModel(character: character)
    }
    
    func makePhotoDetailViewModel(characterName: String, imageURL: URL?) -> PhotoDetailViewModel {
        PhotoDetailViewModel(
            characterName: characterName,
            imageURL: imageURL,
            savePhotoUseCase: makeSavePhotoUseCase()
        )
    }
    
    // MARK: - Initialization
    
    private init() {}
}

// MARK: - Testing Support

#if DEBUG
extension DependencyContainer {
    /// Creates a container with custom dependencies for testing
    static func makeForTesting(
        apiClient: APIClientProtocol? = nil,
        characterRepository: CharacterRepositoryProtocol? = nil,
        photoLibraryRepository: PhotoLibraryRepositoryProtocol? = nil
    ) -> DependencyContainer {
        let container = DependencyContainer()
        // In a real scenario, we'd have setters or a different init for testing
        return container
    }
}
#endif
