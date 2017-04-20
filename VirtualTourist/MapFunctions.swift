//
//  MapFunctions.swift
//  VirtualTourist
//
//  Created by Macbook on 4/10/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapFunctions: NSObject, MKMapViewDelegate {
    
    static var sharedInstance = MapFunctions()
    
    func centerOnMap(mapView: MKMapView, location: CLPlacemark) {
        let mapCenter = CLLocationCoordinate2D.init(latitude: (location.location?.coordinate.latitude)!, longitude: (location.location?.coordinate.longitude)! )
        mapView.setCenter(mapCenter, animated: true)
        mapView.isZoomEnabled = true
    }
    
    func setRegion(mapView: MKMapView){
        print("setregion")
        let mapRegion = UserDefaults.standard.object(forKey: "MapRegion") as! [String:Double]
        let mapCenter = CLLocationCoordinate2D.init(latitude: mapRegion["lat"]!, longitude: mapRegion["lon"]!)
        let longitudeDelta = mapRegion["latDelta"]! as CLLocationDegrees
        let latitudeDelta = mapRegion["lonDelta"]! as CLLocationDegrees
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let savedRegion = MKCoordinateRegion(center: mapCenter, span: span)
        mapView.setRegion(savedRegion, animated: false)
        
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
    
}
