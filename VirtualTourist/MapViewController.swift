//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Macbook on 2/19/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    //properties
    @IBOutlet weak var mapView: MKMapView!
    
    //lifecycle
    override func viewDidLoad(){
        super.viewDidLoad()
        mapView.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotation))
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
        subscribeToBackgroundNotification()
        if UserDefaults.standard.bool(forKey: "HasZoomLevelAndCenter"){
            MapFunctions.sharedInstance.setRegion(mapView: mapView)
        }
        Client.sharedInstance.pinsFromCD(mapView)
    }

    //views
    
    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            Client.sharedInstance.addAnnotation(mapView: mapView, gestureRecognizer: gestureRecognizer)
        }
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
    
    @IBAction func dumpData(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try delegate.stack?.dropAllData()
        } catch {
            print(error)
        }
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
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
            
            //make fetch request
            let request: NSFetchRequest<Locations> = Locations.fetchRequest()
            let precision = 0.0001
            let lat = Double((view.annotation?.coordinate.latitude)!)
            let lon = Double((view.annotation?.coordinate.longitude)!)
            request.predicate = NSPredicate(format: "(latitude BETWEEN {\((lat) - precision),\((lat) + precision) }) AND (longitude BETWEEN {\((lon) - precision),\((lon) + precision) })", argumentArray:[Double((view.annotation?.coordinate.latitude)!), Double((view.annotation?.coordinate.longitude)!)])
            let result = try? Client.sharedInstance.stackManagedObjectContext().fetch(request)
            controller.locationPin = view.annotation?.coordinate
            controller.location = result?[0]
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let mapCenter = CLLocationCoordinate2D.init(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)! )
        mapView.setCenter(mapCenter, animated: true)
        
    }

}
