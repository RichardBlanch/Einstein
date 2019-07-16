//
//  PersistableAPIRequest.swift
//  Einstein iOS
//
//  Created by Richard Blanchard on 7/16/19.
//

import Combine
import Foundation

public protocol PersistableAPIRequest: APIRequest where Self.Output: NSManagedObjectConvertible {
    
}

public extension PersistableAPIRequest {
    func fetchAndPersist(within persistentContainer: PersistentContainer) -> AnyPublisher<Void, Error> {
        future()
            .tryMap { try persistentContainer.persistObject($0) }
            .eraseToAnyPublisher()
    }
}
