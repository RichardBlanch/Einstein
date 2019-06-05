//
//  NSManagedObjectConvertible.swift
//
//

import Foundation
import CoreData

/// A type that can be converted to a managed object. These should be the raw structs that are returned from our APIRequest's ResponseDataType
/// This type must ALSO be Decodable
/// See Story as an example. (Story is converted to StoryEntity)
public protocol NSManagedObjectConvertible: Decodable {
    associatedtype ManagedObject: NSManagedObject

    func toManagedObject(within context: NSManagedObjectContext) -> ManagedObject
}

// MARK: - Example

/*
struct Story: Codable, NSManagedObjectConvertible {
    typealias ManagedObject = StoryEntity
    let id: Int
    
    func toManagedObject(within context: NSManagedObjectContext) -> StoryEntity {
        let storyEntity = StoryEntity(context: context)
        
        storyEntity.managedObjectContext?.performAndWait {
            storyEntity.id = Int64(id)
        }
        
        return storyEntity
    }
}
 */

