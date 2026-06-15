//
//  PhotoLibraryRepositoryProtocol.swift
//  RickAndMortyApp
//
//  Repository protocol for photo library operations.
//  Abstracts Photos framework from the domain layer.
//

import UIKit

// MARK: - Photo Library Repository Protocol

protocol PhotoLibraryRepositoryProtocol {
    /// Checks and requests photo library authorization if needed.
    /// - Returns: Whether access is granted
    func requestAuthorization() async -> Bool
    
    /// Fetches recent photos from the device gallery.
    /// - Parameters:
    ///   - limit: Maximum number of photos to fetch
    ///   - sortOrder: Sort order for photos
    /// - Returns: Array of gallery photos
    func fetchRecentPhotos(limit: Int, sortOrder: PhotoSortOrder) -> [GalleryPhoto]
    
    /// Loads the image for a gallery photo.
    /// - Parameters:
    ///   - photo: The gallery photo to load
    ///   - targetSize: The desired size for the image
    /// - Returns: The loaded image, or nil if unavailable
    func loadImage(for photo: GalleryPhoto, targetSize: CGSize) async -> UIImage?
    
    /// Saves an image to the photo library.
    /// - Parameter image: The image to save
    /// - Throws: Error if save fails
    func saveImage(_ image: UIImage) async throws
}

// MARK: - Photo Library Error

enum PhotoLibraryError: LocalizedError {
    case accessDenied
    case saveFailed(Error?)
    case imageNotFound
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return L10n.Error.photoAccessDenied
        case .saveFailed(let error):
            return error?.localizedDescription ?? L10n.Error.photoSaveFailed
        case .imageNotFound:
            return L10n.Error.photoNotFound
        }
    }
}
