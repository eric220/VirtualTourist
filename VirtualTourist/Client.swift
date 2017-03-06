//
//  Client.swift
//  VirtualTourist
//
//  Created by Macbook on 2/24/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit

class Client {
    
    func getPhotos(){
    }
    
    func VTUrlParameter(parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Url.scheme
        components.host = Constants.Url.host
        components.path = Constants.Url.path
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    static var sharedInstance = Client()
}
