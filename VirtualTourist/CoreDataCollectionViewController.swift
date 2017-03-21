//
//  CoreDataCollectionViewController.swift
//  VirtualTourist
//
//  Created by Macbook on 3/21/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import UIKit
import CoreData

class CoreDataCollectionViewController: UICollectionViewController {
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            //collectionView!.reloadData()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
    // MARK: - CoreDataTableViewController (Subclass Must Implement)
    
    extension CoreDataCollectionViewController {
        
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            fatalError("Implement in subclass")
        }
    }
    
    // MARK: - CoreDataTableViewController (Table Data Source)
    
    extension CoreDataCollectionViewController {
        
        override func numberOfSections(in collectionView: UICollectionView) -> Int {
            if let fc = fetchedResultsController {
                return (fc.sections?.count)!
            } else {
                return 0
            }
        }
        
        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if let fc = fetchedResultsController {
                return fc.sections![section].numberOfObjects
            } else {
                return 0
            }
        }
        
    }
    
    // MARK: - CoreDataTableViewController (Fetches)
    
    extension CoreDataCollectionViewController {
        
        func executeSearch() {
            if let fc = fetchedResultsController {
                do {
                    try fc.performFetch()
                } catch let e as NSError {
                    print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
                }
            }
        }
    }
    
    // MARK: - CoreDataTableViewController: NSFetchedResultsControllerDelegate
    
    extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate {
        
        /*func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            collectionView.beginUpdates()
        }*/
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
            
            let set = IndexSet(integer: sectionIndex)
            
            switch (type) {
            case .insert:
               collectionView?.insertSections(set)
            case .delete:
               collectionView?.deleteSections(set)
            default:
                // irrelevant in our case
                break
            }
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            
            switch(type) {
            case .insert:
                collectionView!.insertItems(at: [newIndexPath!])
            case .delete:
                collectionView?.deleteItems(at: [indexPath!])
            case .update:
                collectionView?.reloadItems(at: [indexPath!])
            case .move:
                collectionView?.deleteItems(at: [indexPath!])
                collectionView?.insertItems(at: [newIndexPath!])
            }
        }
        
        /*func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            collectionView.endUpdates()
        }*/
    }
