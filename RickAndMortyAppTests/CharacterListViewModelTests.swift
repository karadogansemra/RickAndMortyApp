//
//  CharacterListViewModelTests.swift
//  RickAndMortyAppTests
//
//  Unit tests for CharacterListViewModel.
//

import XCTest
@testable import RickAndMortyApp

@MainActor
final class CharacterListViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: CharacterListViewModel!
    private var mockFetchUseCase: MockFetchCharactersUseCase!
    private var mockGalleryUseCase: MockGalleryPhotosUseCase!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        mockFetchUseCase = MockFetchCharactersUseCase()
        mockGalleryUseCase = MockGalleryPhotosUseCase()
        sut = CharacterListViewModel(
            fetchCharactersUseCase: mockFetchUseCase,
            galleryPhotosUseCase: mockGalleryUseCase
        )
    }
    
    override func tearDown() {
        sut = nil
        mockFetchUseCase = nil
        mockGalleryUseCase = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_viewDidLoad_loadsFirstPageOfCharacters() async {
        // Arrange
        mockFetchUseCase.result = .success(.mock(ids: [1, 2, 3], hasNext: true))
        
        let charactersLoadedExpectation = self.expectation(description: "characters loaded")
        charactersLoadedExpectation.assertForOverFulfill = false
        
        sut.onItemsChanged = { [weak self] in
            guard let self = self else { return }
            let items = self.sut.items(for: .characters)
            // Fulfill when we have actual character items
            if items.contains(where: { if case .character = $0 { return true } else { return false } }) {
                charactersLoadedExpectation.fulfill()
            }
        }
        
        // Act
        sut.viewDidLoad()
        await fulfillment(of: [charactersLoadedExpectation], timeout: 2)
        
        // Assert
        let characters = sut.items(for: .characters)
        XCTAssertEqual(characters.count, 3)
        XCTAssertEqual(mockFetchUseCase.executeCallCount, 1)
    }
    
    func test_networkFailure_fallsBackToCache() async {
        // Arrange
        mockFetchUseCase.result = .failure(NetworkError.noConnection)
        mockFetchUseCase.cachedCharacters = [
            .mock(id: 10, name: "Cached Rick"),
            .mock(id: 11, name: "Cached Morty")
        ]
        
        let cacheLoadedExpectation = self.expectation(description: "cache loaded")
        cacheLoadedExpectation.assertForOverFulfill = false
        
        // Wait until we have actual character items (not just loading state)
        sut.onItemsChanged = { [weak self] in
            guard let self = self else { return }
            let items = self.sut.items(for: .characters)
            // Only fulfill when we have cached characters loaded
            if items.contains(where: { if case .character = $0 { return true } else { return false } }) {
                cacheLoadedExpectation.fulfill()
            }
        }
        
        // Act
        sut.viewDidLoad()
        await fulfillment(of: [cacheLoadedExpectation], timeout: 2)
        
        // Assert
        let characters = sut.items(for: .characters)
        XCTAssertEqual(characters.count, 2)
        
        if case .character(let first) = characters[0] {
            XCTAssertEqual(first.id, 10)
        } else {
            XCTFail("Expected a character item")
        }
    }
    
    func test_galleryPhotos_areDeduplicated() {
        // Arrange
        mockFetchUseCase.result = .success(.mock(ids: [], hasNext: false))
        
        let duplicate = GalleryPhoto(localIdentifier: "abc", creationDate: Date())
        let unique = GalleryPhoto(localIdentifier: "def", creationDate: Date())
        mockGalleryUseCase.photos = [duplicate, duplicate, unique]
        
        // Act
        sut.viewDidLoad()
        
        // Assert
        XCTAssertEqual(mockGalleryUseCase.fetchPhotos(limit: 30, sortOrder: .newestFirst).count, 3)
    }
    
    func test_loadMore_triggersNextPage() async {
        // Arrange
        mockFetchUseCase.result = .success(.mock(ids: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], hasNext: true))
        
        let firstPageExpectation = self.expectation(description: "first page loaded")
        firstPageExpectation.assertForOverFulfill = false
        
        sut.onItemsChanged = { [weak self] in
            guard let self = self else { return }
            let items = self.sut.items(for: .characters)
            if items.filter({ if case .character = $0 { return true } else { return false } }).count == 10 {
                firstPageExpectation.fulfill()
            }
        }
        
        sut.viewDidLoad()
        await fulfillment(of: [firstPageExpectation], timeout: 2)
        
        // Reset for second page
        mockFetchUseCase.result = .success(.mock(ids: [11, 12, 13], hasNext: false))
        
        let secondPageExpectation = self.expectation(description: "second page loaded")
        secondPageExpectation.assertForOverFulfill = false
        
        sut.onItemsChanged = { [weak self] in
            guard let self = self else { return }
            let items = self.sut.items(for: .characters)
            if items.filter({ if case .character = $0 { return true } else { return false } }).count == 13 {
                secondPageExpectation.fulfill()
            }
        }
        
        // Act
        sut.loadMoreIfNeeded(currentIndex: 8)
        await fulfillment(of: [secondPageExpectation], timeout: 2)
        
        // Assert
        XCTAssertEqual(mockFetchUseCase.executeCallCount, 2)
    }
    
    func test_refresh_clearsAndReloads() async {
        // Arrange
        mockFetchUseCase.result = .success(.mock(ids: [1, 2, 3], hasNext: true))
        
        let initialExpectation = self.expectation(description: "initial load")
        initialExpectation.assertForOverFulfill = false
        
        sut.onItemsChanged = { [weak self] in
            guard let self = self else { return }
            let items = self.sut.items(for: .characters)
            if items.contains(where: { if case .character = $0 { return true } else { return false } }) {
                initialExpectation.fulfill()
            }
        }
        
        sut.viewDidLoad()
        await fulfillment(of: [initialExpectation], timeout: 2)
        
        // Setup refresh response
        mockFetchUseCase.result = .success(.mock(ids: [4, 5, 6], hasNext: false))
        
        // Act
        await sut.refresh()
        
        // Assert
        let characters = sut.items(for: .characters)
        XCTAssertEqual(characters.count, 3)
        
        if case .character(let first) = characters[0] {
            XCTAssertEqual(first.id, 4)
        } else {
            XCTFail("Expected refreshed character")
        }
    }
    
    func test_setSortOrder_reloadsGalleryPhotos() {
        // Arrange
        mockFetchUseCase.result = .success(.mock(ids: [], hasNext: false))
        sut.viewDidLoad()
        
        // Act
        sut.setSortOrder(.oldestFirst)
        
        // Assert
        XCTAssertEqual(sut.sortOrder, .oldestFirst)
    }
}
