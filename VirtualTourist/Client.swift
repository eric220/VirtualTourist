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

class Client: NSObject, MKMapViewDelegate {
    
    func VTUrlParameter(parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Url.scheme
        components.host = Constants.Url.host
        components.path = Constants.Url.path
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    func getImageFromFlickr(locationPin: CLLocationCoordinate2D, handler: @escaping (_ image: NSData?, _ error: String? )->Void ) {
        
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=a8b2fe2e7a7804d2bd34d88980ce92d7&lat=\(locationPin.latitude)&lon=\(locationPin.longitude)&extras=url_m&nojsoncallback=1&format=json&gallery&per_page=50&radius=20&radius_units=mi"
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
                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                        let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
                        if let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String {
                            let imageURL = NSURL(string: imageUrlString)
                            if let imageData = NSData(contentsOf: imageURL! as URL){
                                handler(imageData, nil)
                            }
                        }
                    }
                }
            }
        }
        task.resume()
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
    
    
    static var sharedInstance = Client()
}
