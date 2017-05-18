//
//  Helper.swift
//  VirtualTourist
//
//  Created by Macbook on 5/18/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class Helper {
    
    func launchAlert(message: String) -> UIAlertController{
        let alert = UIAlertController(title: "Alert", message: "\(message)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        return alert
    }
    
    static var sharedInstance = Helper()
    
}
