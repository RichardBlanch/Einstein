//
//  DeepLinkable.swift
//
//

import Foundation
import UIKit

/// A type that can be generated as a 'Deep Link.' Should be constructed from URLComponents
public protocol DeepLinkable {
    associatedtype HostType
    init?(from urlComponents: URLComponents)

    var urlComponents: URLComponents { get }
    var host: HostType { get }
    func location() -> UIViewController
}

// MARK: - Example

/*
 
struct GrioDeepLink: DeepLinkable {
    typealias HostType = Host
    
    enum Host: String {
        case players
        case teams
        
        init?(host: String) {
            guard let path = Host(rawValue: host) else { return nil }
            
            self = path
        }
    }
    
    let host: Host
    let urlComponents: URLComponents
    
    
    init?(from urlComponents: URLComponents) {
        guard let host = Host(host: urlComponents.host ?? "") else { return nil }
        self.host = host
        self.urlComponents = urlComponents
    }
    
    func location() -> UIViewController {
        switch host {
        case .players:
            let players = PlayersViewController.instantiate()!
            players.title = urlComponents.queryItems?.first(where: { $0.name == "id" })?.value
            return players
        case .teams:
            return TeamsViewController.instantiate()!
        }
    }
}
 */
