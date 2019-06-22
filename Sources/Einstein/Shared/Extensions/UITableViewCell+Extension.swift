//
//  UITableViewCell+Extension.swift
//
//

#if os(iOS)
import Foundation
import UIKit

public extension UITableView {
    func dequeueReusableCell<Cell: UITableViewCell>(_ cellType: Cell.Type, for indexPath: IndexPath) -> Cell {
        return dequeueReusableCell(withIdentifier: String(describing: cellType), for: indexPath) as! Cell
    }
}
#endif
