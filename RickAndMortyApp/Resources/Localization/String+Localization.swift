//
//  String+Localization.swift
//  RickAndMortyApp
//
//  String extension for easy localization access.
//

import Foundation

// MARK: - String Extension

extension String {
    
    /// Returns the localized version of the string.
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Returns the localized version with format arguments.
    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
}

// MARK: - Localization Keys

/// Type-safe localization keys
enum L10n {
    
    // MARK: - General
    enum General {
        static let ok = "ok".localized
        static let error = "error".localized
        static let success = "success".localized
        static let cancel = "cancel".localized
        static let close = "close".localized
        static let save = "save".localized
        static let delete = "delete".localized
        static let loading = "loading".localized
    }
    
    // MARK: - Character List
    enum CharacterList {
        static let title = "characters.title".localized
        static let gallerySection = "characters.section.gallery".localized
        static let charactersSection = "characters.section.characters".localized
        static let sortTitle = "characters.sort.title".localized
        static let sortNewest = "characters.sort.newest".localized
        static let sortOldest = "characters.sort.oldest".localized
    }
    
    // MARK: - Character Detail
    enum CharacterDetail {
        static let status = "character.status".localized
        static let species = "character.species".localized
        static let gender = "character.gender".localized
        static let origin = "character.origin".localized
        static let location = "character.location".localized
    }
    
    // MARK: - Status
    enum Status {
        static let alive = "status.alive".localized
        static let dead = "status.dead".localized
        static let unknown = "status.unknown".localized
    }
    
    // MARK: - Gender
    enum Gender {
        static let male = "gender.male".localized
        static let female = "gender.female".localized
        static let genderless = "gender.genderless".localized
        static let unknown = "gender.unknown".localized
    }
    
    // MARK: - Photo
    enum Photo {
        static let saved = "photo.saved".localized
        static let saveFailed = "photo.saveFailed".localized
    }
    
    // MARK: - Errors
    enum Error {
        static let invalidURL = "error.invalidURL".localized
        static let noConnection = "error.noConnection".localized
        static let decodingFailed = "error.decodingFailed".localized
        static func serverError(_ code: Int) -> String {
            "error.serverError".localized(with: code)
        }
        static let unknown = "error.unknown".localized
        static let photoAccessDenied = "error.photoAccessDenied".localized
        static let photoSaveFailed = "error.photoSaveFailed".localized
        static let photoNotFound = "error.photoNotFound".localized
    }
}
