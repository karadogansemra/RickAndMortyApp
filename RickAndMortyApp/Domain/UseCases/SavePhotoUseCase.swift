//
//  SavePhotoUseCase.swift
//  RickAndMortyApp
//
//  Use case for saving images to the device photo library.
//

import UIKit

// MARK: - Protocol

protocol SavePhotoUseCaseProtocol {
    /// Saves an image to the photo library.
    /// - Parameter image: Image to save
    /// - Throws: PhotoLibraryError if save fails
    func execute(_ image: UIImage) async throws
}

// MARK: - Implementation

final class SavePhotoUseCase: SavePhotoUseCaseProtocol {
    
    // MARK: - Properties
    
    private let repository: PhotoLibraryRepositoryProtocol
    
    // MARK: - Initialization
    
    init(repository: PhotoLibraryRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execution
    
    func execute(_ image: UIImage) async throws {
        let authorized = await repository.requestAuthorization()
        guard authorized else {
            throw PhotoLibraryError.accessDenied
        }
        
        try await repository.saveImage(image)
    }
}
