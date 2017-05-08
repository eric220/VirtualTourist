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
    
    struct Url {
        static let Scheme = "https"
        static let Host = "api.flickr.com"
        static let Path = "/services/rest"
    }
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let PerPage = "per_page"
        static let Radius = "radius"
        static let RadiusUnits = "radius_units=mi"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let Method = "flickr.photos.search"
        static let APIKey = "a8b2fe2e7a7804d2bd34d88980ce92d7"
        static let Extras = "url_m"
        static let Format = "json"
        static let NoJSONCallback = 1
        static let PerPage = 100
        static let Radius = 20
        static let RadiusUnits = "mi"
    }
    
    struct FlickrResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let MediumURL = "url_m"
    }
    
}
