//
//  Image+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Macbook on 3/21/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image");
    }

    @NSManaged public var image: NSData?
    @NSManaged public var location: Locations?

}
