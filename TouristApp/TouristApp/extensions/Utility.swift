//
//  Utility.swift
//  TouristApp
//
//  Created by Hazem on 5/15/19.
//  Copyright © 2019 Hazem. All rights reserved.
//

import Foundation

public func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
    
    var components = URLComponents()
    components.scheme = Constants.Flickr.APIScheme
    components.host = Constants.Flickr.APIHost
    components.path = Constants.Flickr.APIPath
    components.queryItems = [URLQueryItem]()
    
    for (key, value) in parameters {
        let queryItem = URLQueryItem(name: key, value: "\(value)")
        components.queryItems!.append(queryItem)
    }
    
    return components.url!
}


public func isValueValid(_ coordValue: Double?, forRange: (Double, Double)) -> Bool {
    if let value = coordValue {
        return isValueInRange(value, min: forRange.0, max: forRange.1)
    } else {
        return false
    }
}

public func isValueInRange(_ value: Double, min: Double, max: Double) -> Bool {
    return !(value < min || value > max)
}
