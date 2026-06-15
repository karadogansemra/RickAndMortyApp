//
//  PhotoDetailViewModel.swift
//  RickAndMortyApp
//
//  ViewModel for the Photo Detail screen.
//  Handles saving photos to the device gallery.
//

import UIKit

// MARK: - View Model

final class PhotoDetailViewModel {
    
    // MARK: - Properties
    
    let characterName: String
    let imageURL: URL?
    
    private let savePhotoUseCase: SavePhotoUseCaseProtocol
    
    // MARK: - Initialization
    
    init(
        characterName: String,
        imageURL: URL?,
        savePhotoUseCase: SavePhotoUseCaseProtocol
    ) {
        self.characterName = characterName
        self.imageURL = imageURL
        self.savePhotoUseCase = savePhotoUseCase
    }
    
    // MARK: - Actions
    
    func saveToGallery(_ image: UIImage) async throws {
        try await savePhotoUseCase.execute(image)
    }
}
