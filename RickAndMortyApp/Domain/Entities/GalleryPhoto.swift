//
//  GalleryPhoto.swift
//  RickAndMortyApp
//
//  Domain entity representing a photo from the device gallery.
//  Uses local identifier to reference PHAsset without holding heavy objects.
//

import Foundation

// MARK: - Gallery Photo Entity

struct GalleryPhoto: Hashable, Identifiable {
    let id: String
    let localIdentifier: String
    let creationDate: Date?
    
    init(localIdentifier: String, creationDate: Date?) {
        self.id = localIdentifier
        self.localIdentifier = localIdentifier
        self.creationDate = creationDate
    }
}

// MARK: - Sort Order

enum PhotoSortOrder: CaseIterable {
    case newestFirst
    case oldestFirst
    
    var ascending: Bool {
        switch self {
        case .newestFirst: return false
        case .oldestFirst: return true
        }
    }
    
    var displayName: String {
        switch self {
        case .newestFirst: return "Newest First"
        case .oldestFirst: return "Oldest First"
        }
    }
    
    var localizedDisplayName: String {
        switch self {
        case .newestFirst: return L10n.CharacterList.sortNewest
        case .oldestFirst: return L10n.CharacterList.sortOldest
        }
    }
    
    var iconName: String {
        switch self {
        case .newestFirst: return "arrow.down"
        case .oldestFirst: return "arrow.up"
        }
    }
}
