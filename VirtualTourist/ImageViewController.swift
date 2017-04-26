//
//  ImageViewController.swift
//  VirtualTourist
//
//  Created by Macbook on 4/23/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController: UIViewController {
    
    var imageData: Image?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        if let imageData = imageData {
            imageView.image  = UIImage(data: imageData.image as! Data)
        }
    }
    
}
