//
//  ReachabilityManager.swift
//
//

import Foundation
import Network

/// A class that will emit reachability changes.
/// To listen to these changes add a class using addListener(_listener: ReachabilityManagerListener)
public class ReachabilityManager {
    public static let shared = ReachabilityManager()
    
    public var hasConnection: Bool {
        guard let path = path else { return false }

        return path.status == .satisfied
    }
    
    public var isConnectedToCellular: Bool {
        return path?.usesInterfaceType(.cellular) ?? false
    }
    
    public var isConnectedToWifi: Bool {
        return path?.usesInterfaceType(.wifi) ?? false
    }
    
    public var isConnectedToEthernet: Bool {
        return path?.usesInterfaceType(.wiredEthernet) ?? false
    }
    
    private let monitor: NWPathMonitor
    private let dispatchQueue: DispatchQueue
    private var listeners: [ReachabilityManagerListener]
    private var path: NWPath?
    
    private init() {
        self.monitor = NWPathMonitor()
        self.dispatchQueue = DispatchQueue(label: "com.ReachabilityManagerQueue")
        self.listeners = []
        
        monitor.pathUpdateHandler = { [unowned self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.listeners.forEach { $0.reachabilityManager(self, didRecieveConnectionWithPath: path) }
                } else {
                    self.listeners.forEach { $0.reachabilityManager(self, didDropConnectionWithPath: path) }
                }
                
                 self.path = path
            }
        }
        
        self.monitor.start(queue: dispatchQueue)
    }
    
    public func addListener(_ listener: ReachabilityManagerListener) {
        listeners.append(listener)
    }
    
    public func removeListener(_ listener: ReachabilityManagerListener) {
        listeners = listeners.filter { $0 === listener }
    }
}

// MARK: - Example
/* 1.
  ReachabilityManager.shared.addListener(self)
*/

/* 2.
extension ViewController: ReachabilityManagerListener {
    func reachabilityManager(_ reachabilityManager: ReachabilityManager, didRecieveConnectionWithPath path: NWPath) {
        print("WOOHOO! WE'VE GOT WIFI!")
    }
    
    func reachabilityManager(_ reachabilityManager: ReachabilityManager, didDropConnectionWithPath path: NWPath) {
        let alertController = UIAlertController(title: "No wifi :(", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}
 */
