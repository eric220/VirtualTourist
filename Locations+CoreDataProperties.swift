//
//  Locations+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Macbook on 4/20/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import CoreData


extension Locations {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Locations> {
        return NSFetchRequest<Locations>(entityName: "Locations");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var images: NSSet?

}

// MARK: Generated accessors for images
extension Locations {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: Image)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: Image)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}
