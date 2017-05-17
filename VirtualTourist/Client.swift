//
//  Client.swift
//  VirtualTourist
//
//  Created by Macbook on 2/24/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class Client: NSObject, MKMapViewDelegate {
    
    func urlFromComponents(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.host = Constants.Url.Host
        components.scheme = Constants.Url.Scheme
        components.path = Constants.Url.Path
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        return components.url!
        
    }
    
    //get images
    func getImageFromFlickr(location: Locations, numPics: Int, numPage: Int?, handler: @escaping (_ error: String?, _ numPages: Int? )->Void ) {
        
        
        var parameters = [Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
                          Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.Method,
                          "lat":  (location.latitude),
                          "lon":  (location.longitude),
                          Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.Extras,
                          Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.NoJSONCallback,
                          Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.Format,
                          Constants.FlickrParameterKeys.PerPage: numPics,
                          Constants.FlickrParameterKeys.Radius: Constants.FlickrParameterValues.Radius,
                          Constants.FlickrParameterKeys.RadiusUnits: Constants.FlickrParameterValues.RadiusUnits] as [String : Any]
        
        if let numPage = numPage {
            var pageNum = Int()
            let maxPages = 4000/numPics
            if numPage > maxPages{
                pageNum = maxPages
            } else {
                pageNum = numPage
            }
            let ranNum = Int(arc4random_uniform(UInt32(pageNum)))
            parameters[Constants.FlickrParameterKeys.Page] = ranNum
        }
        let tUrl = urlFromComponents(parameters as [String : AnyObject])
        let request = NSURLRequest(url: tUrl)
        let task = URLSession.shared.dataTask(with: request as URLRequest!) {data, response, error in
            func displayError(_ error: String) {
                handler(error, nil)
            }
            guard error == nil else {
                displayError("Difficulty with internet, check connection")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            if let data = data{
                let parsedResult: AnyObject!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                }catch {
                    handler("Could not parse data", nil)
                    return
                }
                if let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject],let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]]{
                    let pages = photosDictionary["pages"] as! Int
                    for object in photoArray {
                        if let imageUrlString = object[Constants.FlickrResponseKeys.MediumURL] {
                            let imageUrl = NSURL(string: imageUrlString as! String)
                            if let imageData = NSData(contentsOf: imageUrl! as URL){
                                let mainQ = DispatchQueue.main
                                mainQ.async { () -> Void in
                                    let photo = Image(image: imageData, context: self.stackManagedObjectContext())
                                    photo.location = location
                                }
                                handler(nil, pages)
                            }
                        }
                    }
                }
            } else {
                handler("No Image Data Returned", nil)
            }
        }
        task.resume()
    }
    
    //create stack
    func stackManagedObjectContext() -> NSManagedObjectContext {
        
        // core data stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        return (stack?.context)!
        
    }
    
    //get latlon from CD and add annotation
    func pinsFromCD(_ mapView: MKMapView, handler: @escaping (_ error: String? )->Void ){
        let request: NSFetchRequest<Locations> = Locations.fetchRequest()
        let result = try? self.stackManagedObjectContext().fetch(request)
        if let result = result {
            for object in result {
                let locale = object
                let location = CLLocation(latitude: (locale.latitude), longitude: (locale.longitude))
                getLocation(location: location){(result, error) in
                    guard error == nil else{
                        handler(error)
                        return
                    }
                    let annotation = MKPointAnnotation()
                    annotation.title = result?[0].locality
                    annotation.subtitle = result?[0].country
                    annotation.coordinate = CLLocationCoordinate2D(latitude: (result?[0].location?.coordinate.latitude)!, longitude: (result?[0].location?.coordinate.longitude)!)
                    mapView.addAnnotation(annotation)
                }
            }
        } else {
            handler("No objects found, try again")
        }
    }
    
    //add annotation to map
    
    func addAnnotation(mapView: MKMapView, gestureRecognizer: UIGestureRecognizer, handler: @escaping (_ error: String? )->Void ) {
        let point = gestureRecognizer.location(in: mapView)
        let touchCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: (touchCoordinate.latitude), longitude: (touchCoordinate.longitude))
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        getLocation(location: location){(result, error) in
            guard error == nil else{
                handler(error)
                return
            }
            _ = Locations(latitude: (result?[0].location?.coordinate.latitude)!, longitude: (result?[0].location?.coordinate.longitude)!, context: (self.stackManagedObjectContext()))
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.stack?.saveContext()
            self.centerOnMap(mapView: mapView, location: (result?[0])!)
            //let annotation = MKPointAnnotation()
            annotation.title = result?[0].locality
            annotation.subtitle = result?[0].country
            annotation.coordinate = CLLocationCoordinate2D(latitude: (result?[0].location?.coordinate.latitude)!, longitude: (result?[0].location?.coordinate.longitude)!)
            mapView.addAnnotation(annotation)
            handler(nil)
        }
    }
    
    func getLocation(location: CLLocation, handler:@escaping (_ result: [CLPlacemark]?, _ error: String?)-> Void){
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location){(data, error) in
            guard error == nil else{
                handler(nil, "Failed to geocode, check network connection")
                return
            }
            handler(data!, nil)
        }
    }
    
    func centerOnMap(mapView: MKMapView, location: CLPlacemark) {
        let mapCenter = CLLocationCoordinate2D.init(latitude: (location.location?.coordinate.latitude)!, longitude: (location.location?.coordinate.longitude)! )
        mapView.setCenter(mapCenter, animated: true)
        mapView.isZoomEnabled = true
    }
    
    func launchAlert(message: String) -> UIAlertController{
        let alert = UIAlertController(title: "Alert", message: "\(message)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        return alert
    }
    
    static var sharedInstance = Client()
    
}
