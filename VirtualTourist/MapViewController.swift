//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Macbook on 2/19/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: CoreDataViewController, MKMapViewDelegate {
    //properties
    @IBOutlet weak var mapView: MKMapView!
    
    
    //lifecycle
    override func viewDidLoad(){
        
        super.viewDidLoad()
        //add press
        mapView.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
        subscribeToBackgroundNotification()
        if UserDefaults.standard.bool(forKey: "HasZoomLevelAndCenter"){
            setRegion()
        }
        if fetchedResultsController?.fetchedObjects?.count != 0 {
        pinsFromCD()
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ImagesViewController") as! ImagesViewController
            let location = mapView.selectedAnnotations[0]
            print("Annotation")
            print(location)
            print("Annotation")
            //use predicate to only pass matching lat lon
            controller.fetchedResultsController = fetchedResultsController
            controller.locationPin = view.annotation?.coordinate
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let point = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            let locations = Locations(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, context: (fetchedResultsController?.managedObjectContext)!)
            print(locations)
            let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            print(location)
            getLocation(location: location){(result, error) in
                self.centerOnMap(location: result![0])
                self.mapView.addAnnotation(MKPlacemark(placemark: result![0]))
            }
        }
    }
    
    //functions
    func getLocation(location: CLLocation, handler:@escaping (_ result: [CLPlacemark]?, _ error: String?)-> Void){
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location){(data, error) in
            guard error == nil else{
                print("cannot geocode")
                handler(nil, "Failed to geocode")
                return
            }
            handler(data!, nil)
        }
    }
    
    func centerOnMap(location: CLPlacemark) {
        let mapCenter = CLLocationCoordinate2D.init(latitude: (location.location?.coordinate.latitude)!, longitude: (location.location?.coordinate.longitude)! )
        mapView.setCenter(mapCenter, animated: true)
        mapView.isZoomEnabled = true
    }
    
    func setRegion(){
        let mapRegion = UserDefaults.standard.object(forKey: "MapRegion") as! [String:Double]
        let mapCenter = CLLocationCoordinate2D.init(latitude: mapRegion["lat"]!, longitude: mapRegion["lon"]!)
        let longitudeDelta = mapRegion["latDelta"]! as CLLocationDegrees
        let latitudeDelta = mapRegion["lonDelta"]! as CLLocationDegrees
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let savedRegion = MKCoordinateRegion(center: mapCenter, span: span)
        self.mapView.setRegion(savedRegion, animated: false)
        
    }
    
    func subscribeToBackgroundNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(storeUserData), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    func unsubscribeToBackgroundNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    //persist region view
    func storeUserData(){
        let mapRegion = [
            "lat" : mapView.region.center.latitude,
            "lon" : mapView.region.center.longitude,
            "latDelta" : mapView.region.span.latitudeDelta,
            "lonDelta" : mapView.region.span.longitudeDelta
        ]
        UserDefaults.standard.set(mapRegion, forKey: "MapRegion")
        UserDefaults.standard.set(true, forKey: "HasZoomLevelAndCenter")
        unsubscribeToBackgroundNotification()
    }
    
    func pinsFromCD(){
        for object in (fetchedResultsController?.fetchedObjects)! {
            let nb = object as? Locations
            let location = CLLocation(latitude: (nb?.latitude)!, longitude: (nb?.longitude)!)
            //print(object)
            getLocation(location: location){(result, error) in
                self.centerOnMap(location: result![0])
                self.mapView.addAnnotation(MKPlacemark(placemark: result![0]))
            }
        }
    }
    
    @IBAction func dumpData(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try delegate.stack?.dropAllData()
        } catch {
            print(error)
        }
        
    }
    
    func updateSearchResults(lat: Double) {
        if (lat <= 90 && lat >= -90) {
            fetchedResultsController?.fetchRequest.predicate = NSPredicate(format: "lattitude =  %.2f", lat)
        } else {
            print("no data found")
        }
        do {
            try self.fetchedResultsController?.performFetch()
        } catch {}
    }
    
}
