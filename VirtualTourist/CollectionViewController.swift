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

class CollectionViewController: UIViewController, MKMapViewDelegate {
    //properties
    var locationPin: CLLocationCoordinate2D?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var image: UIImageView!
    
    //lifecycle
    override func viewDidLoad(){
        super.viewDidLoad()
        mapView.delegate = self
        centerAndZoomMap()
        Client.sharedInstance.getPhotos()
        getImageFromFlickr()
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
    
    //a8b2fe2e7a7804d2bd34d88980ce92d7 
    //Secret:
    //8f7495be0fb6edf9
    
    private func getImageFromFlickr() {
        
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=a8b2fe2e7a7804d2bd34d88980ce92d7&lat=\(locationPin!.latitude)&lon=\(locationPin!.longitude)&extras=url_m&nojsoncallback=1&format=json&gallery&per_page=50"
        print(urlString)
        let url = NSURL(string: urlString)
        let request = NSURLRequest(url: url as! URL)
        print("request:\(request)")
        let task = URLSession.shared.dataTask(with: request as URLRequest!) {data, response, error in
            if error == nil {
                if let data = data{
                    let parsedResult: AnyObject!
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                        //print(parsedResult)
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
                                self.performUIUpdatesOnMain {
                                    self.image.image = UIImage(data: imageData as Data)
                                }
                            }
                        }
                        //print(photoArray[randomPhotoIndex])
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

}
