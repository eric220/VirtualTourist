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
    
    
    //create url
    func VTUrlParameter(parameters: [String:Any]/*, withPathExtension: String? = nil, withHost: String? = nil*/) -> URL {
        var components = URLComponents()
        components.scheme = Constants.Url.Scheme
        print(components.scheme)
        components.host = Constants.Url.Host
        components.path = Constants.Url.Path
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        print(components.url)
        return components.url!
    }
    
    //get images
    func getImageFromFlickr(locationPin: CLLocationCoordinate2D, location: Locations, numPics: Int?, handler: @escaping (_ image: NSData?, _ error: String? )->Void ) {
        /*let parameters = [Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.MethodValue,
                          Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKeyValue,
                          Constants.FlickrParameterKeys.lat: (location.latitude),
                          Constants.FlickrParameterKeys.lon: (location.longitude),
                          Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.ExtrasValue,
                          Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallbackValue,
                          Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.FormatValue,
                          Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPageValue,
                          Constants.FlickrParameterKeys.Radius: Constants.FlickrParameterValues.RadiusValue,
                          Constants.FlickrParameterKeys.RadiusUnits: Constants.FlickrParameterValues.RadiusUnitsValue] as [String : Any]
        let mUrl = VTUrlParameter(parameters: parameters)
        print(parameters)*/
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=a8b2fe2e7a7804d2bd34d88980ce92d7&lat=\(location.latitude)&lon=\(location.longitude)&extras=url_m&nojsoncallback=1&format=json&gallery&per_page=\(numPics!)&radius=20&radius_units=mi"
        let url = NSURL(string: urlString)
        let request = NSURLRequest(url: url as! URL)
        let task = URLSession.shared.dataTask(with: request as URLRequest!) {data, response, error in
            if error == nil {
                if let data = data{
                    let parsedResult: AnyObject!
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                    }catch {
                        print("could not parse data")
                        return
                    }
                    if let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject],let photoArray = photosDictionary["photo"] as? [[String: AnyObject]]{
                        let pageLimit = min(numPics!, 40)
                        let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1

                        for photo in photoArray {
                            if let imageUrlString = photo[Constants.FlickrResponseKeys.MediumURL] as? String {
                                let imageURL = NSURL(string: imageUrlString)
                                if let imageData = NSData(contentsOf: imageURL! as URL){
                                    let photo = Image(image: imageData, context: self.stackManagedObjectContext())
                                    photo.location = location
                                    handler(imageData, nil)
                                }
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    //update main
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
    
    
    //create stack
    func stackManagedObjectContext() -> NSManagedObjectContext {
        
        // core data stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        return (stack?.context)!
        
    }
    
    //get lotlon form CD and add annotation
    func pinsFromCD(_ mapView: MKMapView){
        let request: NSFetchRequest<Locations> = Locations.fetchRequest()
        let result = try? Client.sharedInstance.stackManagedObjectContext().fetch(request)
        if let result = result {
            for object in result {
                let locale = object
                let location = CLLocation(latitude: (locale.latitude), longitude: (locale.longitude))
                MapFunctions.sharedInstance.getLocation(location: location){(result, error) in
                    guard error == nil else{
                        print((error)! as String)
                        return
                    }
                    let annotation = MKPointAnnotation()
                    annotation.title = result?[0].locality
                    annotation.subtitle = result?[0].country
                    annotation.coordinate = CLLocationCoordinate2D(latitude: (result?[0].location?.coordinate.latitude)!, longitude: (result?[0].location?.coordinate.longitude)!)
                    mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    //add annotation to map
    func addAnnotation(mapView: MKMapView, gestureRecognizer: UIGestureRecognizer) {
            let point = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let touchLocation = MKPointAnnotation()
            touchLocation.coordinate = touchCoordinate
            let location = CLLocation(latitude: touchLocation.coordinate.latitude, longitude: touchLocation.coordinate.longitude)
            MapFunctions.sharedInstance.getLocation(location: location){(result, error) in
                guard error == nil else{
                    print((error)! as String)
                    return
                }
                //fails here if over water due to name I think
                _ = Locations(latitude: (result?[0].location?.coordinate.latitude)!, longitude: (result?[0].location?.coordinate.longitude)!, /*name: (result?[0].locality)!,*/ context: (self.stackManagedObjectContext()))
                MapFunctions.sharedInstance.centerOnMap(mapView: mapView, location: (result?[0])!)
                let annotation = MKPointAnnotation()
                annotation.title = result?[0].locality
                annotation.subtitle = result?[0].country
                annotation.coordinate = CLLocationCoordinate2D(latitude: (result?[0].location?.coordinate.latitude)!, longitude: (result?[0].location?.coordinate.longitude)!)
                mapView.addAnnotation(annotation)
            }
    }
    
    static var sharedInstance = Client()
}
