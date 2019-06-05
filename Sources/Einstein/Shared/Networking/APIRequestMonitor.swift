//
//  APIRequestFactory.swift
//
//

import Foundation

/// A class used to throttle Network Requests if needed. Contains a Set of URLS will dispose of these urls when our url has been finished and our throttle time has expired.
class APIRequestMonitor {
    public static let shared = APIRequestMonitor()
    
    private let dispatchQueue = DispatchQueue(label: "com.APIRequestMonitorQueue")
    private var currentlyRequestedURLS = Set<URL>()
    
    ///
    /// - Parameter url: A URL that may or may not be in progress
    /// - Returns: A boolean whether or not the URL is currently in progress or if the throttle time has not elapsed.
    func hasURL(_ url: URL?) -> Bool {
        guard let url = url else { return false }
        return dispatchQueue.sync { return currentlyRequestedURLS.contains(url) }
    }
    
    /// Add a url to our networkMonitor. If we want to throttle this request, we will not make until our throttle time has elapsed
    ///
    /// - Parameter url: A URL
    func add(url: URL?) {
        guard let url = url else { return }

        _ = dispatchQueue.sync { currentlyRequestedURLS.insert(url) }
    }
    
    /// Remove a URL from our network monitor in X seconds where X is the time we want to throttle our request for
    ///
    /// - Parameters:
    ///   - url: a URL
    ///   - throttle: If the same URL is requested to go out, we will wait X seconds where X == throttle
    func remove(url: URL?, with throttle: TimeInterval) {
        guard let url = url else { return }

        let work = DispatchWorkItem {
            self.currentlyRequestedURLS.remove(url)
        }
        
        dispatchQueue.sync {
            DispatchQueue.global().asyncAfter(deadline: .now() + throttle, execute: work)
        }
    }
}
