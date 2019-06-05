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
}

// MARK: - Example

/*
private extension PersistentContainer {
    static let BackgroundQueueLabel = StringKey(rawValue: "com.PersistentContainer.BackgroundQueue")
}
 */
