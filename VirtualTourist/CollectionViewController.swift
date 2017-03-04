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
    
    var locationPin: CLLocationCoordinate2D?
    var location: String?
    
    @IBOutlet weak var labelOutlet: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    //lifecycle
    override func viewDidLoad(){
        super.viewDidLoad()
        labelOutlet.text = location
        mapView.delegate = self
        centerAndZoomMap()
        Client.sharedInstance.getPhotos()
    }
    
    //functions
    func centerAndZoomMap(){
        let mapCenter = CLLocationCoordinate2D.init(latitude: (locationPin?.latitude)!, longitude: (locationPin?.longitude)!)
        let longitudeDelta = CLLocationDegrees(10.0)
        let latitudeDelta = CLLocationDegrees(10.0)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let savedRegion = MKCoordinateRegion(center: mapCenter, span: span)
        self.mapView.setRegion(savedRegion, animated: false)
    }
    
}
