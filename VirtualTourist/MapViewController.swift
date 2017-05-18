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
    
    //MARK: Properties
    
    var annotes = [MKPointAnnotation()]
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var thrashButton: UIBarButtonItem!
    
    //MARK: Lifecycle
    override func viewDidLoad(){
        super.viewDidLoad()
        mapView.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotation))
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
        subscribeToBackgroundNotification()
        if UserDefaults.standard.bool(forKey: "HasZoomLevelAndCenter"){
            setRegion(mapView: mapView)
        }
        Client.sharedInstance.pinsFromCD(mapView){(error) in
            guard error == nil else{
                let alert = Client.sharedInstance.launchAlert(message: error!)
                self.present(alert, animated:  true)
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        thrashButton.tintColor = UIColor.blue
    }
    
    //MARK: Buttons
    @IBAction func dumpData(_ sender: Any) {
        if thrashButton.tintColor == UIColor.red{
            print("delete Pin")
            let annotation = mapView.selectedAnnotations[0]
            print(annotation.coordinate)
            let request: NSFetchRequest<Locations> = Locations.fetchRequest()
            let precision = 0.0001
            let lat = Double((annotation.coordinate.latitude))
            let lon = Double((annotation.coordinate.longitude))
            request.predicate = NSPredicate(format: "(latitude BETWEEN {\((lat) - precision),\((lat) + precision) }) AND (longitude BETWEEN {\((lon) - precision),\((lon) + precision) })", argumentArray:[Double((annotation.coordinate.latitude)), Double((annotation.coordinate.longitude))])
            if let result = try? Client.sharedInstance.stackManagedObjectContext().fetch(request){
                Client.sharedInstance.stackManagedObjectContext().delete(result[0])
            }
            mapView.removeAnnotation(annotation)
        } else {
            let alert = Client.sharedInstance.launchAlert(message: "Are You Sure You Want To Dump All Pins?")
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { action in
                let delegate = UIApplication.shared.delegate as! AppDelegate
                do {
                    try delegate.stack?.dropAllData()
                } catch {
                    print(error)
                }
                let allAnnotations = self.mapView.annotations
                self.mapView.removeAnnotations(allAnnotations)
            }))
            self.present(alert, animated:  true)
        }
    }

    //MARK: Views
    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: mapView)
        let touchCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: (touchCoordinate.latitude), longitude: (touchCoordinate.longitude))
        switch gestureRecognizer.state {
            case .began:
                annotes.append(annotation)
                mapView.addAnnotation(annotation)
            
            case .changed:
                getRemoveLastAnnotations()
                mapView.addAnnotation(annotation)
                annotes.append(annotation)
            
            case .ended:
                activityView.startAnimating()
                getRemoveLastAnnotations()
                Client.sharedInstance.addAnnotation(mapView: mapView, gestureRecognizer: gestureRecognizer){(error) in
                    guard error == nil else{
                        let alert = Client.sharedInstance.launchAlert(message: error!)
                        self.present(alert, animated: true)
                        return
                    }
                    let mainQ = DispatchQueue.main
                    mainQ.async { () -> Void in
                        self.activityView.stopAnimating()
                    }
                }
                annotes.removeAll()
            
            default:
                print("default")
        }
    }
    
    //MARK: Functions
    func getRemoveLastAnnotations(){
        mapView.removeAnnotations(annotes)
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
            if let result = try? Client.sharedInstance.stackManagedObjectContext().fetch(request){
                controller.locationPin = view.annotation?.coordinate
                controller.location = result[0]
                self.navigationController!.pushViewController(controller, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let mapCenter = CLLocationCoordinate2D.init(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)! )
        thrashButton.tintColor = UIColor.red
        mapView.setCenter(mapCenter, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        thrashButton.tintColor = UIColor.blue
    }
    
    func setRegion(mapView: MKMapView){
        let mapRegion = UserDefaults.standard.object(forKey: "MapRegion") as! [String:Double]
        let mapCenter = CLLocationCoordinate2D.init(latitude: mapRegion["lat"]!, longitude: mapRegion["lon"]!)
        let longitudeDelta = mapRegion["latDelta"]! as CLLocationDegrees
        let latitudeDelta = mapRegion["lonDelta"]! as CLLocationDegrees
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let savedRegion = MKCoordinateRegion(center: mapCenter, span: span)
        mapView.setRegion(savedRegion, animated: false)
        
    }

}
