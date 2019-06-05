//
//  Instantiable.swift
//
//

import Foundation
import UIKit

/// A protocol used to instantiate a UIViewController. Called using: *ViewController.instantiate()
public protocol Instantiable {
    static var storyboard: UIStoryboard? { get }
    static var identifier: String { get }
}

public extension Instantiable where Self: UIViewController {
    static var identifier: String {
        return String(describing: self)
    }
    
    static func instantiate() -> Self? {
        return storyboard?.instantiateViewController(withIdentifier: identifier) as? Self
    }
}

// MARK: - Example

/* 1.
class TeamsViewController: UIViewController, Instantiable {
    static var storyboard: UIStoryboard? {
        return UIStoryboard.main
    }
}
*/

/* 2. TeamsViewController.instantiate()
 */
