//
//  Image+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Macbook on 3/21/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import CoreData

@objc(Image)
public class Image: NSManagedObject {
    convenience init(image: NSData?, urlString: String, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Image", in: context) {
            self.init(entity: ent, insertInto: context)
            self.image = image
            self.ulrString = urlString
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
