//
//  ConfigurationKey.swift
//
//

import Foundation

public struct ConfigurationKey: ExpressibleByStringLiteral, RawRepresentable, Hashable {
    public let rawValue: String
    
    public init(stringLiteral value: String) {
        rawValue = value
    }
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
