//
//  DeepLinkManager.swift
//
//

import Foundation

/// A type that can generated deepLinks given a DeepLinkable type. Meant to be subclassed.
open class DeepLinkManager<T: DeepLinkable> {
    
    public init() {
    }

    open func parseDeepLink(from url: URL) -> T? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        var pathComponents = components.path.components(separatedBy: "/")
        // the first component is empty
        pathComponents.removeFirst()
        
        return T(from: components)
    }
}

// MARK: - Example

/*
class GrioDeepLinkManager: DeepLinkManager<GrioDeepLink> {
}
*/
