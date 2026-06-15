//
//  PhotoLibraryRepository.swift
//  RickAndMortyApp
//
//  Repository implementation for photo library operations.
//  Wraps the Photos framework.
//

import Photos
import UIKit

// MARK: - Implementation

final class PhotoLibraryRepository: PhotoLibraryRepositoryProtocol {
    
    // MARK: - Properties
    
    private let imageManager: PHCachingImageManager
    
    // MARK: - Initialization
    
    init() {
        self.imageManager = PHCachingImageManager()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            return true
            
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                    continuation.resume(returning: newStatus == .authorized || newStatus == .limited)
                }
            }
            
        default:
            return false
        }
    }
    
    // MARK: - Fetch Photos
    
    func fetchRecentPhotos(limit: Int, sortOrder: PhotoSortOrder) -> [GalleryPhoto] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: sortOrder.ascending)]
        options.fetchLimit = limit
        
        let assets = PHAsset.fetchAssets(with: .image, options: options)
        var photos: [GalleryPhoto] = []
        
        assets.enumerateObjects { asset, _, _ in
            let photo = GalleryPhoto(
                localIdentifier: asset.localIdentifier,
                creationDate: asset.creationDate
            )
            photos.append(photo)
        }
        
        return photos
    }
    
    // MARK: - Load Image
    
    func loadImage(for photo: GalleryPhoto, targetSize: CGSize) async -> UIImage? {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [photo.localIdentifier], options: nil)
        
        guard let asset = assets.firstObject else {
            return nil
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        options.isSynchronous = false
        
        return await withCheckedContinuation { continuation in
            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                // Check if this is the final, non-degraded image
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                if !isDegraded {
                    continuation.resume(returning: image)
                }
            }
        }
    }
    
    // MARK: - Save Image
    
    func saveImage(_ image: UIImage) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: PhotoLibraryError.saveFailed(error))
                }
            }
        }
    }
}
