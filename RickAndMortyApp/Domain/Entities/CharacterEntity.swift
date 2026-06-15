//
//  CharacterEntity.swift
//  RickAndMortyApp
//
//  Domain entity representing a Rick & Morty character.
//  This is the core business model, independent of data layer details.
//

import Foundation

// MARK: - Character Entity

struct CharacterEntity: Hashable, Identifiable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let gender: CharacterGender
    let origin: Location
    let location: Location
    let imageURL: URL?
    
    // MARK: - Hashable
    
    static func == (lhs: CharacterEntity, rhs: CharacterEntity) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Character Status

enum CharacterStatus: String, CaseIterable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"
    
    init(rawValue: String) {
        switch rawValue.lowercased() {
        case "alive": self = .alive
        case "dead": self = .dead
        default: self = .unknown
        }
    }
    
    var displayName: String {
        switch self {
        case .alive: return "Alive"
        case .dead: return "Dead"
        case .unknown: return "Unknown"
        }
    }
    
    var localizedDisplayName: String {
        switch self {
        case .alive: return L10n.Status.alive
        case .dead: return L10n.Status.dead
        case .unknown: return L10n.Status.unknown
        }
    }
}

// MARK: - Character Gender

enum CharacterGender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case genderless = "Genderless"
    case unknown = "unknown"
    
    init(rawValue: String) {
        switch rawValue.lowercased() {
        case "male": self = .male
        case "female": self = .female
        case "genderless": self = .genderless
        default: self = .unknown
        }
    }
    
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .genderless: return "Genderless"
        case .unknown: return "Unknown"
        }
    }
    
    var localizedDisplayName: String {
        switch self {
        case .male: return L10n.Gender.male
        case .female: return L10n.Gender.female
        case .genderless: return L10n.Gender.genderless
        case .unknown: return L10n.Gender.unknown
        }
    }
}

// MARK: - Location

struct Location: Hashable {
    let name: String
    let url: String
    
    static let unknown = Location(name: "Unknown", url: "")
}

// MARK: - Pagination Info

struct PaginationInfo {
    let totalCount: Int
    let totalPages: Int
    let nextPageURL: URL?
    let previousPageURL: URL?
    
    var hasNextPage: Bool { nextPageURL != nil }
    var hasPreviousPage: Bool { previousPageURL != nil }
}

// MARK: - Paginated Response

struct PaginatedCharacters {
    let characters: [CharacterEntity]
    let pagination: PaginationInfo
}
