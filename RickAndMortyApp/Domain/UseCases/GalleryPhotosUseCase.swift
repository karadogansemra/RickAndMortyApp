//
//  GalleryPhotosUseCase.swift
//  RickAndMortyApp
//
//  Use case for fetching and managing gallery photos.
//  Handles deduplication and sorting of device photos.
//

import UIKit

// MARK: - Protocol

protocol GalleryPhotosUseCaseProtocol {
    /// Requests photo library authorization.
    /// - Returns: Whether access is granted
    func requestAuthorization() async -> Bool
    
    /// Fetches gallery photos with deduplication.
    /// - Parameters:
    ///   - limit: Maximum number of photos
    ///   - sortOrder: Sort order for photos
    /// - Returns: Unique gallery photos
    func fetchPhotos(limit: Int, sortOrder: PhotoSortOrder) -> [GalleryPhoto]
    
    /// Loads an image for a gallery photo.
    /// - Parameters:
    ///   - photo: Gallery photo to load
    ///   - targetSize: Desired image size
    /// - Returns: Loaded image
    func loadImage(for photo: GalleryPhoto, targetSize: CGSize) async -> UIImage?
}

// MARK: - Implementation

final class GalleryPhotosUseCase: GalleryPhotosUseCaseProtocol {
    
    // MARK: - Properties
    
    private let repository: PhotoLibraryRepositoryProtocol
    
    // MARK: - Initialization
    
    init(repository: PhotoLibraryRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execution
    
    func requestAuthorization() async -> Bool {
        await repository.requestAuthorization()
    }
    
    func fetchPhotos(limit: Int, sortOrder: PhotoSortOrder) -> [GalleryPhoto] {
        let photos = repository.fetchRecentPhotos(limit: limit, sortOrder: sortOrder)
        
        // Deduplicate by localIdentifier (requirement: photos should not repeat)
        var seen = Set<String>()
        return photos.filter { photo in
            guard !seen.contains(photo.localIdentifier) else { return false }
            seen.insert(photo.localIdentifier)
            return true
        }
    }
    
    func loadImage(for photo: GalleryPhoto, targetSize: CGSize) async -> UIImage? {
        await repository.loadImage(for: photo, targetSize: targetSize)
    }
}
