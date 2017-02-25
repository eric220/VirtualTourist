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
    
    var locationPin: CLPlacemark?
    
    @IBOutlet weak var labelOutlet: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var location: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelOutlet.text = location
        mapView.delegate = self
        Client.sharedInstance.getPhotos()
    }
    
}
