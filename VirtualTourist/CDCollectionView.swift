//
//  CDCollectionView.swift
//  VirtualTourist
//
//  Created by Macbook on 3/21/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import UIKit
import CoreData

class CDCollectionView: UICollectionView
{
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchedResultsController?.delegate = self
            executeSearch()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dataSource = self
    }
}

extension CDCollectionView: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("this method MUST be implemented by a subclass of CDCollectionView")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        }
        return 0
    }
}

extension CDCollectionView
{
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            }
            catch let e as NSError {
                print("error while trying to perform fetch on: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}

extension CDCollectionView: NSFetchedResultsControllerDelegate
{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // TODO: implement
        print("preparing to change content")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // TODO: implement
        print("object changes")
        switch type {
        case .delete: break
        case .insert: break
        case .move: break
        case .update: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        // TODO: implement
        print("section changes")
        switch type {
        case .delete: break
        case .insert: break
        case .move: break
        case .update: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // TODO: implement
        print("finished changing content")
    }
}
