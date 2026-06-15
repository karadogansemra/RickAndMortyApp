//
//  CharacterDetailViewModel.swift
//  RickAndMortyApp
//
//  ViewModel for the Character Detail screen.
//  Provides formatted character information for display.
//

import Foundation

// MARK: - Info Row

struct CharacterInfoRow {
    let title: String
    let value: String
}

// MARK: - View Model

final class CharacterDetailViewModel {
    
    // MARK: - Properties
    
    private let character: CharacterEntity
    
    // MARK: - Computed Properties
    
    var name: String { character.name }
    
    var imageURL: URL? { character.imageURL }
    
    var infoRows: [CharacterInfoRow] {
        [
            CharacterInfoRow(title: L10n.CharacterDetail.status, value: character.status.localizedDisplayName),
            CharacterInfoRow(title: L10n.CharacterDetail.species, value: character.species),
            CharacterInfoRow(title: L10n.CharacterDetail.gender, value: character.gender.localizedDisplayName),
            CharacterInfoRow(title: L10n.CharacterDetail.origin, value: character.origin.name),
            CharacterInfoRow(title: L10n.CharacterDetail.location, value: character.location.name)
        ]
    }
    
    // MARK: - Initialization
    
    init(character: CharacterEntity) {
        self.character = character
    }
}
