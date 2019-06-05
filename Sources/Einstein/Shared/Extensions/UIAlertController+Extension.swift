//
//  UIAlertController+Extension.swift
//
//

import Foundation
import UIKit

public extension UIAlertController {
    static func alertController(from alertControllerError: AlertControllerError, actions: [UIAlertAction], preferredStyle: UIAlertController.Style = .alert) -> UIAlertController? {
        guard alertControllerError.showsError else { return nil }

        let alertController = UIAlertController(title: alertControllerError.title, message: alertControllerError.message, preferredStyle: preferredStyle)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        return alertController
    }
}

// MARK: - Example

/*
private func showAlert(from alertControllerError: AlertControllerError) {
    DispatchQueue.main.async { [weak self] in
        if let alertController = UIAlertController.alertController(from: alertControllerError, actions: [UIAlertAction(title: "OK", style: .default, handler: nil)]) {
            self?.present(alertController, animated: true, completion: nil)
        }
    }
}
 */
