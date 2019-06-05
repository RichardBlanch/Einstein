//
//  FetchedResultsViewController.swift
//
//

import Foundation
import CoreData
import UIKit

public protocol FetchedResultsControllerTableViewController {
    associatedtype FetchResultType: NSFetchRequestResult
    
    var tableView: UITableView! { get set }
    var fetchedResultsController: NSFetchedResultsController<FetchResultType> { get set }
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath)
}


// MARK: - UITableViewDataSource

extension FetchedResultsControllerTableViewController {
    public func defaultNumberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    public func defaultTableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension FetchedResultsControllerTableViewController {
    public func defaultControllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    
    public func defaultController(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let section = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            tableView.insertSections(section, with: .fade)
        case .delete:
            tableView.deleteSections(section, with: .fade)
        default: break
        }
    }
    
    public func defaultController(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            guard let cell = tableView.cellForRow(at: indexPath!) else { return }
            configureCell(cell, indexPath: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        @unknown default:
            fatalError()
        }
    }
    
    public func defaultControllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
