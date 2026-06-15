//
//  Mocks.swift
//  RickAndMortyAppTests
//
//  Mock implementations for testing.
//

import UIKit
@testable import RickAndMortyApp

// MARK: - Mock API Client

final class MockAPIClient: APIClientProtocol {
    var result: Result<CharacterListResponseDTO, Error> = .failure(NetworkError.unknown)
    var requestCallCount = 0
    
    func request<T: Decodable>(_ endpoint: RickAndMortyEndpoint) async throws -> T {
        requestCallCount += 1
        switch result {
        case .success(let response):
            guard let response = response as? T else {
                throw NetworkError.decodingFailed(NSError(domain: "", code: 0))
            }
            return response
        case .failure(let error):
            throw error
        }
    }
    
    static func makeResponse(ids: [Int], hasNext: Bool) -> CharacterListResponseDTO {
        let characters = ids.map { id in
            CharacterDTO(
                id: id,
                name: "Character \(id)",
                status: "Alive",
                species: "Human",
                gender: "Male",
                origin: LocationDTO(name: "Earth", url: ""),
                location: LocationDTO(name: "Earth", url: ""),
                image: "https://rickandmortyapi.com/api/character/avatar/\(id).jpeg"
            )
        }
        let info = PageInfoDTO(
            count: 826,
            pages: 42,
            next: hasNext ? "https://rickandmortyapi.com/api/character?page=2" : nil,
            prev: nil
        )
        return CharacterListResponseDTO(info: info, results: characters)
    }
}

// MARK: - Mock Character Repository

final class MockCharacterRepository: CharacterRepositoryProtocol {
    var fetchResult: Result<PaginatedCharacters, Error> = .failure(NetworkError.unknown)
    var cachedCharacters: [CharacterEntity] = []
    var savedCharacters: [CharacterEntity] = []
    var fetchCallCount = 0
    
    func fetchCharacters(page: Int, nextURL: URL?) async throws -> PaginatedCharacters {
        fetchCallCount += 1
        switch fetchResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    func cacheCharacters(_ characters: [CharacterEntity], page: Int) {
        savedCharacters.append(contentsOf: characters)
    }
    
    func loadCachedCharacters() -> [CharacterEntity] {
        cachedCharacters
    }
    
    func clearCache() {
        cachedCharacters.removeAll()
        savedCharacters.removeAll()
    }
}

// MARK: - Mock Photo Library Repository

final class MockPhotoLibraryRepository: PhotoLibraryRepositoryProtocol {
    var isAuthorized = true
    var photos: [GalleryPhoto] = []
    var savedImages: [UIImage] = []
    var shouldFailSave = false
    
    func requestAuthorization() async -> Bool {
        isAuthorized
    }
    
    func fetchRecentPhotos(limit: Int, sortOrder: PhotoSortOrder) -> [GalleryPhoto] {
        Array(photos.prefix(limit))
    }
    
    func loadImage(for photo: GalleryPhoto, targetSize: CGSize) async -> UIImage? {
        UIImage(systemName: "photo")
    }
    
    func saveImage(_ image: UIImage) async throws {
        if shouldFailSave {
            throw PhotoLibraryError.saveFailed(nil)
        }
        savedImages.append(image)
    }
}

// MARK: - Mock Fetch Characters Use Case

final class MockFetchCharactersUseCase: FetchCharactersUseCaseProtocol {
    var result: Result<PaginatedCharacters, Error> = .failure(NetworkError.unknown)
    var cachedCharacters: [CharacterEntity] = []
    var executeCallCount = 0
    
    func execute(page: Int, nextURL: URL?) async throws -> PaginatedCharacters {
        executeCallCount += 1
        switch result {
        case .success(let characters):
            return characters
        case .failure(let error):
            throw error
        }
    }
    
    func loadCachedCharacters() -> [CharacterEntity] {
        cachedCharacters
    }
}

// MARK: - Mock Gallery Photos Use Case

final class MockGalleryPhotosUseCase: GalleryPhotosUseCaseProtocol {
    var isAuthorized = true
    var photos: [GalleryPhoto] = []
    
    func requestAuthorization() async -> Bool {
        isAuthorized
    }
    
    func fetchPhotos(limit: Int, sortOrder: PhotoSortOrder) -> [GalleryPhoto] {
        Array(photos.prefix(limit))
    }
    
    func loadImage(for photo: GalleryPhoto, targetSize: CGSize) async -> UIImage? {
        UIImage(systemName: "photo")
    }
}

// MARK: - Test Helpers

extension CharacterEntity {
    static func mock(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: CharacterStatus = .alive
    ) -> CharacterEntity {
        CharacterEntity(
            id: id,
            name: name,
            status: status,
            species: "Human",
            gender: .male,
            origin: Location(name: "Earth", url: ""),
            location: Location(name: "Citadel of Ricks", url: ""),
            imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/\(id).jpeg")
        )
    }
}

extension PaginatedCharacters {
    static func mock(ids: [Int], hasNext: Bool = false) -> PaginatedCharacters {
        PaginatedCharacters(
            characters: ids.map { .mock(id: $0, name: "Character \($0)") },
            pagination: PaginationInfo(
                totalCount: 826,
                totalPages: 42,
                nextPageURL: hasNext ? URL(string: "https://rickandmortyapi.com/api/character?page=2") : nil,
                previousPageURL: nil
            )
        )
    }
}
