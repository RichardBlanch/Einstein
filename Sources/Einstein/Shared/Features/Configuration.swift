//
//  Configuration.swift
//
//

import Foundation

public enum Configuration {
    public static func value<T>(for configurationKey: ConfigurationKey) -> T {
        guard let value = Bundle.main.infoDictionary?[configurationKey.rawValue] as? T else {
            fatalError("Invalid or missing Info.plist key: \(configurationKey.rawValue)")
        }
        
        return value
    }
}
