//
//  RequestFactory.swift
//  iCasting
//
//  Created by T. van Steenoven on 08-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

enum ICMethod {
    case post,get,put,patch,delete
    
    func getDescription() -> String {
        switch self {
        case .post:
            return "POST"
        case .get:
            return "GET"
        default:
            return ""
        }
    }
}

typealias paramsType = [String:String]?

/* Define the protocols for the Requests */

protocol RequestProtocol {
    func create(endpoint:EndpointProtocol, content: (insert:[String]?, params:paramsType)) -> NSURLRequest
}
protocol JSONRequestProtocol {
    func create(endpoint:EndpointProtocol, content:(insert:[String]?, params:[String:AnyObject]) ) -> NSURLRequest
}
protocol RequestHeaderProtocol {
    func create(endpoint:EndpointProtocol, content:(insert:[String]?, params:[String:AnyObject]), withHeaders: [String:String] ) -> NSURLRequest
    func create(endpoint:EndpointProtocol, content:(insert:[String]?, params:paramsType), withHeaders: [String:String] ) -> NSURLRequest
}
protocol SerializerCommand {
    func execute() -> NSData
}

/* The factory get the right request type depending on the given ICMethod */

class RequestFactory {
    
    class func request(method:ICMethod) -> RequestProtocol {
        
        var requestType:RequestProtocol
        
        switch method {
        case .get:
            requestType = GetRequest()
        case .post:
            requestType = PostRequest()
        default:
            requestType = GetRequest()
        }
        
        return requestType
    }
    
    static var GET: RequestProtocol {
        return GetRequest()
    }

    static var POST: RequestProtocol {
        return PostRequest()
    }
}

/* All the request types  */

private struct GetRequest: RequestProtocol {
    
    func create(endpoint:EndpointProtocol, content: (insert:[String]?, params:paramsType) ) -> NSURLRequest {
        
        let url: NSURL = ICURL.createURL(endpoint, insert: content.insert, params: content.params)
        let request = NSURLRequest(URL: url)
        return request
    }
}

private struct PostRequest: RequestProtocol {
    
    /* Normal request */
    func create(endpoint:EndpointProtocol, content: (insert:[String]?, params:paramsType) ) -> NSURLRequest {
        
        println("PostRequest: Will invoke normal request")
        let url: NSURL = ICURL.createURL(endpoint, insert: content.insert, params: nil)
        var request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = ICMethod.post.getDescription()
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        
        // Check if the params are set, which needs to be with a post request
        if let p = content.params {
            println("Parameters to set: ")
            println(p)
            request.HTTPBody = SerializeParametersCommand(params:p).execute()
        }
        else {
            println("Post request doesn't have a body")
        }
        
        return request
    }
}

extension PostRequest : JSONRequestProtocol {
    
    /* JSON Request */
    func create(endpoint:EndpointProtocol, content:(insert:[String]?, params:[String:AnyObject]) ) -> NSURLRequest {
        
        let url: NSURL = ICURL.createURL(endpoint, insert: content.insert, params: nil)
        var request = NSMutableURLRequest(URL: url)
        request.HTTPBody = SerializeJSONCommand(params: content.params).execute()
        return request
    }
}

extension PostRequest : RequestHeaderProtocol {

    /* Normal Request with headers */
    func create(endpoint:EndpointProtocol, content:(insert:[String]?, params:paramsType), withHeaders: [String:String] ) -> NSURLRequest {
        println("PostRequest: Will invoke normal request with headers")
        var request: NSMutableURLRequest = self.create(endpoint, content: content) as! NSMutableURLRequest
        for (key, value) in withHeaders {
            request.addValue(value, forHTTPHeaderField: key)
            println(key, value)
        }
        return request
    }
    
    /* JSON Request with headers */
    func create(endpoint:EndpointProtocol, content:(insert:[String]?, params:[String:AnyObject]), withHeaders: [String:String] ) -> NSURLRequest {
        
        var request: NSMutableURLRequest = self.create(endpoint, content: content) as! NSMutableURLRequest
        for (key, value) in withHeaders { request.addValue(key, forHTTPHeaderField: value) }
        return request
    }

}

/* The commands to serialize the request data to send */

private struct SerializeJSONCommand : SerializerCommand {
    
    var params:[String:AnyObject]
    func execute() -> NSData {
        var data : NSData
        if NSJSONSerialization.isValidJSONObject(params) {

            let errorPointer : NSErrorPointer = NSErrorPointer()
            data = NSJSONSerialization.dataWithJSONObject(
                params,
                options: nil,
                error: errorPointer
            )!
        } else {
            println("Not valid JSON object")
            data = NSData()
        }
        return data
    }
}

private struct SerializeParametersCommand : SerializerCommand {
    
    var params:paramsType
    func execute() -> NSData {
        
        var data : NSData = self.encode().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        return data
    }
    
    func construct() -> String {
        var str : String = ""
        for (key, value) in params!  {
            str = str+key+"="+value+"&"
        }
        str = (str as NSString).substringToIndex(count(str)-1)
        return str
    }
    
    func encode() -> String {
        
        var mcs : NSMutableCharacterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        mcs.addCharactersInString(".=&")
        
        var str : String  = self.construct().stringByAddingPercentEncodingWithAllowedCharacters(mcs)!
        
        return str
    }
}






