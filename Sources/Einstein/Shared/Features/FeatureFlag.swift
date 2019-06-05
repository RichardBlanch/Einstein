//
//  FeatureFlag.swift
//
//

import Foundation

// Feature Flags for your app.
/// Should load this from Network or Config File.
/// See GrioFeatureFlags as an example.
public protocol FeatureFlags {
    /// Use to configure your feature flags from a dictionary
    init(from jsonObject: JSONObject)
}

public extension FeatureFlags {
    init(from data: Data) throws {
        let jsonObject = try JSONSerialization.jsonObject(from: data)
        
        self.init(from: jsonObject)
    }
}

public extension JSONObject where Key == String {
    subscript<V>(_ key: Key, default defaultExpression: @autoclosure () -> V) -> V {
        return value(for: key, default: defaultExpression())
    }

    private func value<V>(for key: Key,
                  default defaultExpression: @autoclosure () -> V) -> V {
        return (self[key] as? V) ?? defaultExpression()
    }
}

// MARK: - Example

/*
class GrioExampleFeatureFlags: FeatureFlags {
    let color: UIColor
    
    required init(from jsonObject: JSONObject) {
        self.color = jsonObject["color", default: UIColor.red]
    }
}
 */



