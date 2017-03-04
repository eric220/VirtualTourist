//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Macbook on 2/19/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    //properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    //lifecycle
    override func viewDidLoad(){
        super.viewDidLoad()
        mapView.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
        subscribeToBackgroundNotification()
        if UserDefaults.standard.bool(forKey: "HasZoomLevelAndCenter"){
        setRegion()
        }
    }

    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let point = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            getLocation(location: location){(result, error) in
                self.centerOnMap(location: result![0])
                self.mapView.addAnnotation(MKPlacemark(placemark: result![0]))
            }
        }
    }
   
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
            if let toOpen = view.annotation?.title! {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController
                controller.location = toOpen
                controller.locationPin = view.annotation?.coordinate
                //controller.locationPin =
                self.navigationController!.pushViewController(controller, animated: true)
            }
        }
    }
    
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
        //mapView.setCenter(mapCenter, animated: true)
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
}
