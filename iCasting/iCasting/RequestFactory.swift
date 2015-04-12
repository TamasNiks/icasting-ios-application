//
//  RequestFactory.swift
//  iCasting
//
//  Created by T. van Steenoven on 08-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

//struct Methods {
//    static let POST : String = "POST"
//    static let GET : String = "GET"
//    static let PUT : String = "PUT"
//    static let PATCH : String = "PATCH"
//    static let DELETE : String = "DELETE"
//}

enum Method {
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

protocol RequestProtocol {
    func request(endpoint:EndpointProtocol, content: (id:String?, body:[String:AnyObject]?)) -> NSURLRequest
}

class RequestFactory {
    
    class func requestType(method:Method) -> RequestProtocol? {
        
        var requestType:RequestProtocol?
        
        switch method {
        case .get:
            requestType = GetRequest()
        case .post:
            requestType = PostRequest()
        default:
            requestType = nil
        }
        
        return requestType
    }
    
    }


private struct GetRequest: RequestProtocol {
    
    func request(endpoint:EndpointProtocol, content: (id:String?, body:[String:AnyObject]?) ) -> NSURLRequest {
        
        var contentID : String? = nil
        if let id = content.id {
            contentID = id
        }
        
        let url: NSURL = URLSimpleFactory.createURL(endpoint, id: contentID)
        let request = NSURLRequest(URL: url)
        
        return request
    }
    
    
}

private struct PostRequest: RequestProtocol {

    func request(endpoint:EndpointProtocol, content: (id:String?, body:[String:AnyObject]?) ) -> NSURLRequest {
        
        let url: NSURL = URLSimpleFactory.createURL(endpoint, id: content.id!)
        var request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = Method.post.getDescription()
        
        if let body = content.body {
            
            let errorPointer : NSErrorPointer = NSErrorPointer()
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(
                body,
                options: NSJSONWritingOptions.PrettyPrinted,
                error: errorPointer)
        }
        else {
            println("Post request doesn't have a body")
        }
        
        return request
    }
    
}

private struct PutRequest: RequestProtocol {
    
    private func request(endpoint: EndpointProtocol, content: (id: String?, body: [String : AnyObject]?)) -> NSURLRequest {
        
        return NSURLRequest()
        
    }
    
}

private struct DeleteRequest: RequestProtocol {
    
    private func request(endpoint: EndpointProtocol, content: (id: String?, body: [String : AnyObject]?)) -> NSURLRequest {
        
        return NSURLRequest()
        
    }
    
}


