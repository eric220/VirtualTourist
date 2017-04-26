//
//  Constants.swift
//  VirtualTourist
//
//  Created by Macbook on 3/4/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    struct Keys {
        static let APIKey = "a8b2fe2e7a7804d2bd34d88980ce92d7"
        static let APISecret = "8f7495be0fb6edf9" 
    }
    
    struct Url {
        static let Scheme = "https"
        static let Host = "api.flickr.com"
        static let Path = "services/rest"
    }
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let PerPage = "per_page"
        static let Radius = "radius"
        static let RadiusUnits = "radius_units"
        
        static let lat = "lat"
        static let lon = "lon"
        //static let GalleryID = "gallery_id"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let MethodValue = "flickr.photos.search"
        static let APIKeyValue = "a8b2fe2e7a7804d2bd34d88980ce92d7"
        static let ExtrasValue = "url_m"
        static let FormatValue = "json"
        static let DisableJSONCallbackValue = "1" /* 1 means "yes" */
        static let PerPageValue = 100
        static let RadiusValue = 20
        static let RadiusUnitsValue = "mi"
        //static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        //static let GalleryID = "5704-72157622566655097"
        //static let APIKey = "c9796bd6195cd1fba57a7d08bfd8d713"
    }
    
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
    }
    
}
