//
//  StringKey.swift
//
//

import Foundation

public struct StringKey: RawRepresentable {
    public typealias RawValue = String

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    static func value<T>(for type: T) -> StringKey {
        let descriptor = "com." + String(describing: type)

        return StringKey(rawValue: descriptor)
    }
}


// MARK: - Example

/*
private extension PersistentContainer {
    static let BackgroundQueueLabel = StringKey(rawValue: "com.PersistentContainer.BackgroundQueue")
}
 */
