//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Macbook on 2/19/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CollectionViewController: UIViewController, MKMapViewDelegate{
    //properties
    var locationPin: CLLocationCoordinate2D?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var addAlbumButton: UIButton!
    
    //lifecycle
    override func viewDidLoad(){
        super.viewDidLoad()
        mapView.delegate = self
        centerAndZoomMap()
        loadImage()
        addAlbumButton.isEnabled = false
    }
    
    func loadImage(){
        Client.sharedInstance.getImageFromFlickr(locationPin: locationPin!){(image, error) in
            guard error == nil else{
                print(error!)
                return
            }
            if let imageData = image {
                self.performUIUpdatesOnMain {
                    self.image.image = UIImage(data: imageData as Data)
                }
            }
        }
    }
    
    //views
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
    
    //functions
    func centerAndZoomMap(){
        let mapCenter = locationPin
        print("lat:\(locationPin?.latitude), lon:\(locationPin?.longitude)")
        let longitudeDelta = CLLocationDegrees(10.0)
        let latitudeDelta = CLLocationDegrees(10.0)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let savedRegion = MKCoordinateRegion(center: mapCenter!, span: span)
        self.mapView.setRegion(savedRegion, animated: true)
        let annotation = MKPointAnnotation.init()
        annotation.coordinate = mapCenter!
        self.mapView.addAnnotation(annotation)
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    private func escapeParameters(parameters: [String: AnyObject]) -> String{
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePair = [String]()
            
            for (key, value) in parameters{
                let stringValue = "\(value)"
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                keyValuePair.append(key + "=" + "\(escapedValue!)")
            }
            return "?\(keyValuePair.joined(separator: "&"))"
        }
    }
    
    /*override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) 
        // Set the image
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }*/

}
