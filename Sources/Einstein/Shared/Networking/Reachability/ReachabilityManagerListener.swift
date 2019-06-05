//
//  ReachabilityManagerListener.swift
//
//

import Foundation
import Network

/// A protocol used for classes that want to listen to reachability updates.
/// `import Network` in the class that you declare as a 'ReachabilityManagerListener'
public protocol ReachabilityManagerListener: class {
    func reachabilityManager(_ reachabilityManager: ReachabilityManager, didRecieveConnectionWithPath path: NWPath)
    func reachabilityManager(_ reachabilityManager: ReachabilityManager, didDropConnectionWithPath path: NWPath)
}
