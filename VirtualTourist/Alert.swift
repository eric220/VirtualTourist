//
//  Alert.swift
//  VirtualTourist
//
//  Created by Macbook on 2/9/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit

func launchAlert(message: String) -> UIAlertController{
    let alert = UIAlertController(title: "Alert", message: "\(message)", preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
    return alert
}
