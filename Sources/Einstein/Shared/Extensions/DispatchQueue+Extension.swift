//
//  DispatchQueue+Extension.swift
//  GrioCommon iOS
//
//  Created by Richard Blanchard on 5/14/19.
//

import Foundation

public extension DispatchQueue {
    convenience init<T: RawRepresentable>(rawRepresentable: T) where T.RawValue == String {
        self.init(label: rawRepresentable.rawValue)
    }
    
    convenience init(from key: StringKey) {
        self.init(rawRepresentable: key)
    }
}

// MARK: - Example

/*
let newQueue = DispatchQueue(from: PersistentContainer.BackgroundQueueLabel)
 
 private extension PersistentContainer {
    static let BackgroundQueueLabel = StringKey(rawValue: "com.PersistentContainer.BackgroundQueue")
 }
*/
