//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Macbook on 2/19/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ImagesViewController: UIViewController {
    //MARK: Properties
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var locationPin: CLLocationCoordinate2D?
    var location: Locations?
    let maxCount = 12
    var page: Int?
    let delegate = UIApplication.shared.delegate as! AppDelegate

    
    //create fetched result controlller
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Image> = {
        // Create Fetch Request
        let request: NSFetchRequest<Image> = Image.fetchRequest()
        // Configure Fetch Request
        request.sortDescriptors = [NSSortDescriptor(key: "location", ascending: true)]
        request.predicate = NSPredicate(format: "location = %@", argumentArray: [self.location!])
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Client.sharedInstance.stackManagedObjectContext(), sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addAlbumButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    //MARK: Lifecycle
    override func viewDidLoad(){
        super.viewDidLoad()
        centerZoomMap(mapView: mapView, locationPin: locationPin)
        setFlowLayout()
        executeSearch()
        if ((fetchedResultsController.fetchedObjects?.count)! == 0){
            getPics()
        }
    }
    
    //MARK: Buttons
    @IBAction func getNewAlbum(_ sender: Any) {
        let count = (fetchedResultsController.fetchedObjects?.count)! - 1
        if count >= 1 {
            for i in 0...count {
                Client.sharedInstance.stackManagedObjectContext().delete(fetchedResultsController.object(at: [0,i]))
            }
        }
        collectionView.reloadData()
        executeSearch()
        getPics()
    }
    
    //MARK: Functions
    func getPics(){
        addAlbumButton.isEnabled = false
        activityView.startAnimating()
        self.view.bringSubview(toFront: activityView)
        Client.sharedInstance.getURLFromFlickr(location: location!, numPics: maxCount, numPage: page){(pages, error) in
            if error != nil {
                let alert = Helper.sharedInstance.launchAlert(message: error!)
                self.present(alert, animated: true)
            }
            self.page = pages
        }
    }
    
    func setFlowLayout(){
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 4.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}



extension ImagesViewController {
        func executeSearch() {
            do {
                try self.fetchedResultsController.performFetch()
            } catch {
                let fetchError = error as NSError
                print("Unable to Perform Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
}

extension ImagesViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func centerZoomMap(mapView: MKMapView, locationPin: CLLocationCoordinate2D?){
        let mapCenter = locationPin
        let longitudeDelta = CLLocationDegrees(3.0)
        let latitudeDelta = CLLocationDegrees(3.0)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let savedRegion = MKCoordinateRegion(center: mapCenter!, span: span)
        mapView.setRegion(savedRegion, animated: true)
        let annotation = MKPointAnnotation.init()
        annotation.coordinate = mapCenter!
        mapView.addAnnotation(annotation)
    }
    
}

//collection view delegate
extension ImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = (fetchedResultsController.fetchedObjects?.count)!
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell",
                                                      for: indexPath) as! imageCell

        let newImage = fetchedResultsController.object(at: indexPath)
        if let imageFromCD = newImage.image {
            cell.collectionImage.image = UIImage(data: imageFromCD as Data)
            return cell
        } else {
            let newImageURL = newImage.ulrString
            Client.sharedInstance.getImage(imagePath: newImageURL!){(data, error)in
                guard error == nil else{// do something else with error. ie use as placemark
                    print(error ?? "error")
                    return
                }
                let mainQ = DispatchQueue.main
                mainQ.async { () -> Void in
                    self.addAlbumButton.isEnabled = true
                    self.activityView.stopAnimating()
                    newImage.image = data as NSData?
                    self.delegate.stack?.saveContext()
                    cell.collectionImage.image = UIImage(data: data!)
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            Client.sharedInstance.stackManagedObjectContext().delete(self.fetchedResultsController.object(at: indexPath))
    }
    
    //this ensures more items are in frc than object selected
    func collectionCount(indexPath: IndexPath) -> Bool{
        let count = ((fetchedResultsController.fetchedObjects?.count)!) - 1
        let objCount = indexPath[1]
        return count >= objCount
    }
}


//controller delegate
extension ImagesViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            delegate.stack?.saveContext()
            collectionView.reloadData()
        case .update:
            break
        default:
            //moving items is not needed
            break
        }
    }
}



