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

class ImagesViewController: UIViewController, MKMapViewDelegate {
    //properties
    var locationPin: CLLocationCoordinate2D?
    var location: Locations?
    let maxCount = 12
    
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
    
    //lifecycle
    override func viewDidLoad(){
        super.viewDidLoad()
        mapView.delegate = self
        centerAndZoomMap()
        setFlowLayout()
        executeSearch()
        if ((fetchedResultsController.fetchedObjects?.count)! < maxCount){
            getPics()
        }
    }
    
    func getPics(){
        addAlbumButton.isEnabled = false
        let numOfPicsNeeded = (maxCount  - (fetchedResultsController.fetchedObjects?.count)!)
        Client.sharedInstance.getImageFromFlickr(locationPin: locationPin!, location: location!, numPics: numOfPicsNeeded){(image, error) in
            guard error == nil else{
                print(error!)
                return
            }
            let mainQ = DispatchQueue.main
            mainQ.async { () -> Void in
                self.addAlbumButton.isEnabled = true
            }
        }
    }
    
    func setFlowLayout(){
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 4.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    //functions
    func centerAndZoomMap(){
        let mapCenter = locationPin
        let longitudeDelta = CLLocationDegrees(10.0)
        let latitudeDelta = CLLocationDegrees(10.0)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let savedRegion = MKCoordinateRegion(center: mapCenter!, span: span)
        self.mapView.setRegion(savedRegion, animated: true)
        let annotation = MKPointAnnotation.init()
        annotation.coordinate = mapCenter!
        self.mapView.addAnnotation(annotation)
    }
    
    @IBAction func getNewAlbum(_ sender: Any) {
        let count = (fetchedResultsController.fetchedObjects?.count)! - 1
        for i in 0...count {
            Client.sharedInstance.stackManagedObjectContext().delete(fetchedResultsController.object(at: [0,i]))
        }
        executeSearch()
        getPics()
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

extension ImagesViewController {
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
    
}

//collection view delegate
extension ImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return (fetchedResultsController.fetchedObjects?.count)!
        return maxCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell",
                                                      for: indexPath) as! imageCell
        print(indexPath)
        print(fetchedResultsController.fetchedObjects?.count)
        if ((fetchedResultsController.fetchedObjects?.count)! != 0) {
            print("not nil")
            print(indexPath)
            let newImage = fetchedResultsController.object(at: indexPath)
            cell.collectionImage.image  = UIImage(data:newImage.image as! Data)
            print("end")
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Client.sharedInstance.stackManagedObjectContext().delete(fetchedResultsController.object(at: indexPath))
        getPics()
    }
}


//controller delegate
extension ImagesViewController: NSFetchedResultsControllerDelegate {
    
    // for automatically update collection view if data base changes
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
}


