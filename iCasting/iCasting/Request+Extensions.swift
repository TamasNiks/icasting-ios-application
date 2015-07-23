//
//  Request+Extensions.swift
//  iCasting
//
//  Created by Tim van Steenoven on 20/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

@objc public protocol ResponseObjectSerializable {
    init?(response: NSHTTPURLResponse, representation: AnyObject)
}

@objc public protocol ResponseCollectionSerializable {
    static func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [Self]
}


// Extends the request to add a custom response serializer generic objects and collection of objects. The object or collection should conform to ResponseObjectSerializable in order to use it with the response

extension Request {
    
    public func responseCollection<T: ResponseCollectionSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, NSError?) -> Void) -> Self {
        
        // Create the serializer which represents a closure. The serializer is to transform the response data in a meaningfull object
        let serializer: Serializer = { (request, response, data) -> (AnyObject?, NSError?) in
            
            // Get the JSON response serializer
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            
            let (json: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            
            if response != nil && json != nil {
                
                return (T.collection(response: response!, representation: json!), nil)
                
            } else {
                
                return (nil, serializationError)
            }
        }
        
        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
            
            completionHandler(request, response, object as? [T], error)
            
        })
    }
    
    public func responseObject<T: ResponseObjectSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void) -> Self {
        
        // First create a serializer which has the form of a closure
        let serializer: Serializer = { (request, response, data) -> (AnyObject?, NSError?) in
            
            // Use the Alomfire JSON response serializer
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            
            let (json: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            
            if response != nil && json != nil {
                
                // Because the generic object conforms to ResponseObjectSerializable, you can call it's protocol method. In this case the init.
                // This will return the object and an nil error
                return (T(response: response!, representation: json!), nil)
                
            } else {
                
                return (nil, serializationError)
                
            }
        }
        
        
        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
            
            completionHandler(request, response, object as? T, error)
        })
    }
}