//
//  CoreDataStack.swift
//  RickAndMortyApp
//
//  Core Data stack with programmatic model definition.
//  No .xcdatamodeld file needed - model is built at runtime.
//  Used for offline caching of character data.
//

import CoreData

// MARK: - Core Data Stack

final class CoreDataStack {
    
    // MARK: - Properties
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Initialization
    
    init(inMemory: Bool = false) {
        let model = Self.createManagedObjectModel()
        container = NSPersistentContainer(name: "RickAndMortyApp", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                // In production, this would be reported to Crashlytics
                assertionFailure("CoreData failed to load: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Model Creation
    
    private static func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // CachedCharacter entity
        let characterEntity = NSEntityDescription()
        characterEntity.name = "CachedCharacter"
        characterEntity.managedObjectClassName = NSStringFromClass(CachedCharacter.self)
        
        characterEntity.properties = [
            createAttribute("id", type: .integer64AttributeType),
            createAttribute("name", type: .stringAttributeType),
            createAttribute("status", type: .stringAttributeType),
            createAttribute("species", type: .stringAttributeType),
            createAttribute("gender", type: .stringAttributeType),
            createAttribute("originName", type: .stringAttributeType),
            createAttribute("originURL", type: .stringAttributeType, optional: true),
            createAttribute("locationName", type: .stringAttributeType),
            createAttribute("locationURL", type: .stringAttributeType, optional: true),
            createAttribute("imageURL", type: .stringAttributeType),
            createAttribute("page", type: .integer64AttributeType),
            createAttribute("sortIndex", type: .integer64AttributeType)
        ]
        
        model.entities = [characterEntity]
        return model
    }
    
    private static func createAttribute(
        _ name: String,
        type: NSAttributeType,
        optional: Bool = false
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        return attribute
    }
    
    // MARK: - Save
    
    func save() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            assertionFailure("CoreData save failed: \(error)")
        }
    }
    
    // MARK: - Background Context
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }
}

// MARK: - Cached Character Entity

@objc(CachedCharacter)
final class CachedCharacter: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var name: String
    @NSManaged var status: String
    @NSManaged var species: String
    @NSManaged var gender: String
    @NSManaged var originName: String
    @NSManaged var originURL: String?
    @NSManaged var locationName: String
    @NSManaged var locationURL: String?
    @NSManaged var imageURL: String
    @NSManaged var page: Int64
    @NSManaged var sortIndex: Int64
}

// MARK: - Mapping

extension CachedCharacter {
    func toDomain() -> CharacterEntity {
        CharacterEntity(
            id: Int(id),
            name: name,
            status: CharacterStatus(rawValue: status),
            species: species,
            gender: CharacterGender(rawValue: gender),
            origin: Location(name: originName, url: originURL ?? ""),
            location: Location(name: locationName, url: locationURL ?? ""),
            imageURL: URL(string: imageURL)
        )
    }
    
    func update(from entity: CharacterEntity, page: Int, sortIndex: Int64) {
        self.id = Int64(entity.id)
        self.name = entity.name
        self.status = entity.status.rawValue
        self.species = entity.species
        self.gender = entity.gender.rawValue
        self.originName = entity.origin.name
        self.originURL = entity.origin.url
        self.locationName = entity.location.name
        self.locationURL = entity.location.url
        self.imageURL = entity.imageURL?.absoluteString ?? ""
        self.page = Int64(page)
        self.sortIndex = sortIndex
    }
}
