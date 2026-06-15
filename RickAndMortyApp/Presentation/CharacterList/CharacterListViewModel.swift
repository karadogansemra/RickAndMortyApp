//
//  CharacterListViewModel.swift
//  RickAndMortyApp
//
//  ViewModel for the Character List screen.
//  Manages:
//   - Paginated character fetching with offline fallback
//   - Gallery photo retrieval with deduplication
//   - Sort order for gallery photos
//

import Foundation
import Combine

// MARK: - List Section

enum ListSection: Int, CaseIterable {
    case gallery = 0
    case characters = 1
    case picsumPhotos = 2  // TODO: Disabled - change order when enabling
}

// MARK: - List Item

enum ListItem: Hashable {
    case galleryPhoto(GalleryPhoto)
    case picsumPhoto(PicsumPhoto)
    case character(CharacterEntity)
    case loading
}

/// Simple model for Picsum photos - fetched from xcconfig URL
struct PicsumPhoto: Hashable, Decodable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let downloadUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url
        case downloadUrl = "download_url"
    }
    
    var thumbnailURL: URL? {
        AppConfiguration.API.picsumImageBaseURL
            .appendingPathComponent("id/\(id)/200/200")
    }
    
    var fullImageURL: URL? {
        URL(string: downloadUrl)
    }
}

// MARK: - View Model

@MainActor
final class CharacterListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var galleryItems: [ListItem] = []
    @Published private(set) var picsumItems: [ListItem] = []
    @Published private(set) var characterItems: [ListItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var sortOrder: PhotoSortOrder = .newestFirst
    
    // MARK: - Callbacks (for UIKit binding)
    
    var onItemsChanged: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Pagination State
    
    private var currentPage = 0
    private var nextPageURL: URL?
    private var hasMorePages = true
    private var isLoadingPage = false
    
    // MARK: - Dependencies
    
    private let fetchCharactersUseCase: FetchCharactersUseCaseProtocol
    private let galleryPhotosUseCase: GalleryPhotosUseCaseProtocol
    
    // MARK: - Constants
    
    private enum Constants {
        static let galleryPhotoLimit = 30
        static let paginationThreshold = 6
    }
    
    // MARK: - Initialization
    
    init(
        fetchCharactersUseCase: FetchCharactersUseCaseProtocol,
        galleryPhotosUseCase: GalleryPhotosUseCaseProtocol
    ) {
        self.fetchCharactersUseCase = fetchCharactersUseCase
        self.galleryPhotosUseCase = galleryPhotosUseCase
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        loadGalleryPhotos()
        // TODO: Uncomment to enable Picsum Photos section
        // loadPicsumPhotos()
        Task { await loadNextPage() }
    }
    
    // MARK: - Refresh
    
    func refresh() async {
        currentPage = 0
        nextPageURL = nil
        hasMorePages = true
        characterItems.removeAll()
        await loadNextPage()
    }
    
    // MARK: - Pagination
    
    func loadMoreIfNeeded(currentIndex: Int) {
        guard hasMorePages, !isLoadingPage else { return }
        
        let threshold = characterItems.count - Constants.paginationThreshold
        guard currentIndex >= threshold else { return }
        
        Task { await loadNextPage() }
    }
    
    // MARK: - Gallery
    
    func setSortOrder(_ order: PhotoSortOrder) {
        sortOrder = order
        loadGalleryPhotos()
    }
    
    // MARK: - Data Access
    
    func items(for section: ListSection) -> [ListItem] {
        switch section {
        case .gallery: return galleryItems
        case .picsumPhotos: return picsumItems
        case .characters: return characterItems
        }
    }
    
    // MARK: - Private Methods
    
    // TODO: Uncomment to enable Picsum Photos section
    /*
    private func loadPicsumPhotos() {
        Task {
            do {
                let photos: [PicsumPhoto] = try await SimpleAPIClient.shared.fetch(
                    from: AppConfiguration.API.picsumBaseURL,
                    path: "/list",
                    query: ["page": "1", "limit": "10"]
                )
                picsumItems = photos.map { .picsumPhoto($0) }
                onItemsChanged?()
            } catch {
                // Silently continue if Picsum fails to load
                print("⚠️ Picsum photos failed to load: \(error.localizedDescription)")
            }
        }
    }
    */
    
    // MARK: - Gallery
    
    private func loadGalleryPhotos() {
        Task {
            let granted = await galleryPhotosUseCase.requestAuthorization()
            guard granted else { return }
            
            let photos = galleryPhotosUseCase.fetchPhotos(
                limit: Constants.galleryPhotoLimit,
                sortOrder: sortOrder
            )
            
            await MainActor.run {
                galleryItems = photos.map { .galleryPhoto($0) }
                onItemsChanged?()
            }
        }
    }
    
    private func loadNextPage() async {
        guard hasMorePages, !isLoadingPage else { return }
        
        isLoadingPage = true
        isLoading = true
        showLoadingFooter(true)
        
        do {
            let result = try await fetchWithRetry(page: currentPage + 1, nextURL: nextPageURL)
            
            currentPage += 1
            nextPageURL = result.pagination.nextPageURL
            hasMorePages = result.pagination.hasNextPage
            
            appendCharacters(result.characters)
            
        } catch {
            handleError(error)
        }
        
        isLoadingPage = false
        isLoading = false
        showLoadingFooter(false)
    }
    
    /// Retry logic for rate-limited requests (HTTP 429)
    private func fetchWithRetry(
        page: Int,
        nextURL: URL?,
        maxRetries: Int = 3,
        initialDelay: TimeInterval = 1.0
    ) async throws -> PaginatedCharacters {
        var lastError: Error?
        
        for attempt in 0..<maxRetries {
            do {
                return try await fetchCharactersUseCase.execute(page: page, nextURL: nextURL)
            } catch let error as NetworkError where error.isRetryable {
                lastError = error
                // Exponential backoff: 1s, 2s, 4s
                let delay = initialDelay * pow(2.0, Double(attempt))
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            } catch {
                throw error
            }
        }
        
        throw lastError ?? NetworkError.unknown
    }
    
    private func appendCharacters(_ characters: [CharacterEntity]) {
        let newItems = characters.map { ListItem.character($0) }
        characterItems.append(contentsOf: newItems)
        onItemsChanged?()
    }
    
    private func showLoadingFooter(_ show: Bool) {
        characterItems.removeAll { $0 == .loading }
        if show {
            characterItems.append(.loading)
        }
        onItemsChanged?()
    }
    
    private func handleError(_ error: Error) {
        self.error = error
        
        // Offline fallback: show cached characters if this is the first page
        // Check for actual character items, not loading indicators
        let hasCharacters = characterItems.contains {
            if case .character = $0 { return true }
            return false
        }
        
        if currentPage == 0 && !hasCharacters {
            let cached = fetchCharactersUseCase.loadCachedCharacters()
            if !cached.isEmpty {
                characterItems = cached.map { .character($0) }
                hasMorePages = false
                onItemsChanged?()
            }
        }
        
        // Notify UI of error
        if let networkError = error as? NetworkError {
            onError?(networkError.localizedDescription)
        } else {
            onError?(error.localizedDescription)
        }
    }
}
