//
//  PersistentContainer.swift
//
//

import Foundation
import CoreData


/*
Use `PersistentContainer.shared` as your 'Core Data Stack'
Use `persistObjects(_)` to save data on a background thread
Use `fetch(_)` to execute a fetch request
Use `batchDelete(_) OR deleteObjects(_)` to delete instances of NSManagedObjects
*/

/// A class to use to interface with Core Data.
/// Based upon: https://developer.apple.com/documentation/coredata/setting_up_a_core_data_stack `Subclass the Persistent Container`
/// Also uses concepts from: https://developer.apple.com/documentation/coredata/loading_and_displaying_a_large_data_feed
public class PersistentContainer: NSPersistentContainer {

    // MARK: Types

    public enum Error: Swift.Error {
        enum BatchDeleteError: Swift.Error {
            case couldNotCastToNSBatchDeleteResult
            case couldNotCastToNSManagedObjectID
        }
    }

    public static let shared = PersistentContainer(for: nil)
    private static let batchSize = 256
    
    private convenience init(for bundle: Bundle? = nil) {
        let bundle = bundle ?? PersistentContainer.findBundle()
        let modelName = PersistentContainer.findModelName(in: bundle) ?? "GrioExample" // TODO: Fix this
        self.init(name: modelName)

        loadPersistentStores(completionHandler: { (storeDescription, error) in
            guard error == nil else {
                assertionFailure("Error: \(String(describing: error))")
                return
            }
        })
        
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        viewContext.undoManager = nil
        viewContext.shouldDeleteInaccessibleFaults = true
    }
    
    // MARK: - Helper
    
    // MARK: Public
    
    public func fetchedResultsController<FetchableObject: NSFetchRequestResult>(for fetchRequest: NSFetchRequest<FetchableObject>, sectionNameKeyPath: String? = nil, cacheName: String? = nil) -> NSFetchedResultsController<FetchableObject> {
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }
    
    public func fetch<FetchableObject: NSFetchRequestResult>(_ fetchRequest: NSFetchRequest<FetchableObject>) throws -> [FetchableObject] {
        return try viewContext.fetch(fetchRequest)
    }
    
    public func persistObject<ManagedObjectConvertible: NSManagedObjectConvertible>(_ object: ManagedObjectConvertible) throws {
        try persistObjects([object])
    }
    
    public func persistObjects<ManagedObjectConvertible: NSManagedObjectConvertible>(_ objects: [ManagedObjectConvertible]) throws {
        let batchSize = PersistentContainer.batchSize
        let count = objects.count
        
        var numBatches = count / batchSize
        numBatches += count % batchSize > 0 ? 1 : 0
        
        for batchNumber in 0..<numBatches {
            let batchStart = batchNumber * batchSize
            let batchEnd = batchStart + min(batchSize, count - batchNumber * batchSize)
            let range = batchStart..<batchEnd
            
            try importOneBatch(Array(objects[range]))
        }
    }

    /// A batch delete that will automatically update your fetchedResultsController's objects in memory.
    public func batchDelete<FetchRequest: NSFetchRequestResult>(from fetchRequest: NSFetchRequest<FetchRequest>) throws {
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        batchDelete.resultType = .resultTypeObjectIDs

        // If the entities that are being deleted are not loaded into memory, there is no need to update your application after the NSBatchDeleteRequest has been executed. However, if you are deleting objects in the persistence layer and those entities are also in memory, it is important that you notify the application that the objects in memory are stale and need to be refreshed. (Typically if you run a batch delete, FRC's will not be notified of the changes)
        guard let batchDeleteExecutionResult = try viewContext.execute(batchDelete) as? NSBatchDeleteResult else {
            throw Error.BatchDeleteError.couldNotCastToNSBatchDeleteResult
        }

        guard let objectIDArray = batchDeleteExecutionResult.result as? [NSManagedObjectID] else {
            throw Error.BatchDeleteError.couldNotCastToNSManagedObjectID
        }
        
        let changes = [NSDeletedObjectsKey: objectIDArray]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
    }
    
    public func deleteObject(_ object: NSManagedObject) throws {
        try deleteObjects([object])
    }

    public func deleteObjects(_ objects: [NSManagedObject]) throws {
        print("Using deleteObjects(_)... Should you use batch delete instead?")

        let viewContext = self.viewContext
        
        viewContext.performAndWait {
            for object in objects {
                viewContext.delete(object)
            }
        }
        
        try viewContext.save()
    }
    
    // MARK: - Instance
    
    private func importOneBatch<ManagedObjectConvertible: NSManagedObjectConvertible>(_ objects: [ManagedObjectConvertible]) throws {
        try performBackgroundBlock { (context) in
            for managedObjectConvertible in objects {
                _ = managedObjectConvertible.toManagedObject(within: context)
            }
        }
    }
    
    private func performBackgroundBlock(_ block: @escaping (NSManagedObjectContext) -> Void) throws {
        let newQueue = DispatchQueue(from: PersistentContainer.BackgroundQueueLabel)
        try newQueue.sync {
            let taskContext = newBackgroundContext()
            taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            taskContext.performAndWait {
                block(taskContext)
            }
            
            if taskContext.hasChanges {
                try taskContext.save()
            }
            
            taskContext.reset()
        }
    }
}

// MARK: - Constant

private extension PersistentContainer {
    static let BackgroundQueueLabel = StringKey(rawValue: "com.PersistentContainer.BackgroundQueue")
}

// MARK: - Helpers to Find Core Data Model

private extension PersistentContainer {
    static func findBundle() -> Bundle {
        let bundleContaingCoreDataModel = Bundle.allBundles.first(where: { $0.urls(forResourcesWithExtension: "momd", subdirectory: nil) != nil })
        
        return bundleContaingCoreDataModel ?? Bundle.main
    }
    
    static func findModelName(in bundle: Bundle) -> String? {
        var relativeUrlString = bundle.urls(forResourcesWithExtension: "momd", subdirectory: nil)?.first?.relativeString
        relativeUrlString = relativeUrlString?.replacingOccurrences(of: ".momd", with: "")
        relativeUrlString = relativeUrlString?.replacingOccurrences(of: "/", with: "")
        
        return relativeUrlString
    }
}
