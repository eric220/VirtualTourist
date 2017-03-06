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
        static let scheme = "https"
        static let host = "flickr"
        static let path = "photos.search"
    }
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let APIKey = "c9796bd6195cd1fba57a7d08bfd8d713"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
    }
    
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
    }
    
}
