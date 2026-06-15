//
//  CharacterDTO.swift
//  RickAndMortyApp
//
//  Data Transfer Objects for Rick & Morty API responses.
//  These map directly to the API JSON structure.
//

import Foundation

// MARK: - Character List Response

struct CharacterListResponseDTO: Decodable {
    let info: PageInfoDTO
    let results: [CharacterDTO]
}

// MARK: - Page Info

struct PageInfoDTO: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

// MARK: - Character

struct CharacterDTO: Decodable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
    let origin: LocationDTO
    let location: LocationDTO
    let image: String
}

// MARK: - Location

struct LocationDTO: Decodable {
    let name: String
    let url: String
}

// MARK: - Mapping to Domain Entities

extension CharacterListResponseDTO {
    func toDomain() -> PaginatedCharacters {
        PaginatedCharacters(
            characters: results.map { $0.toDomain() },
            pagination: info.toDomain()
        )
    }
}

extension PageInfoDTO {
    func toDomain() -> PaginationInfo {
        PaginationInfo(
            totalCount: count,
            totalPages: pages,
            nextPageURL: next.flatMap { URL(string: $0) },
            previousPageURL: prev.flatMap { URL(string: $0) }
        )
    }
}

extension CharacterDTO {
    func toDomain() -> CharacterEntity {
        CharacterEntity(
            id: id,
            name: name,
            status: CharacterStatus(rawValue: status),
            species: species,
            gender: CharacterGender(rawValue: gender),
            origin: origin.toDomain(),
            location: location.toDomain(),
            imageURL: URL(string: image)
        )
    }
}

extension LocationDTO {
    func toDomain() -> Location {
        Location(name: name, url: url)
    }
}
