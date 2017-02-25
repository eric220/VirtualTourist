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
    }

    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let point = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            getLocation(location: location){(result, error) in
                print(result!)
                self.centerOnMap(location: result![0])
                self.mapView.addAnnotation(MKPlacemark(placemark: result![0]))
                annotation.title = "\(result![0].locality!),\(result![0].administrativeArea!)"
                print("\(result![0].locality!), \(result![0].administrativeArea!)")
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
    
    //respond to tap to launch url
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.title! {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController
                controller.location = toOpen
                
                self.navigationController!.pushViewController(controller, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print(mapView.region)
        print("changed region")
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
        let location = CLLocationCoordinate2D.init(latitude: (location.location?.coordinate.latitude)!, longitude: (location.location?.coordinate.longitude)! )
        mapView.setCenter(location, animated: true)
        mapView.isZoomEnabled = true
    }
}
