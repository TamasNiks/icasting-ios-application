//
//  Endpoints.swift
//  iCasting
//
//  Created by T. van Steenoven on 08-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

protocol EndpointProtocol {
    func endpoint() -> String
}

enum APITest: Int, EndpointProtocol {
    
    case TestID
    
    func endpoint() -> String {
        switch self {
        default:
            return "test/:id"
        }
    }
}

enum APIAuth : Int, EndpointProtocol {
    
    case Login, LoginFacebook, LoginTwitter, LoginGoogle, Logout
    
    func endpoint() -> String {
        
        switch self {
        case .Login:
            return "login"
        case .LoginFacebook:
            return "login/facebook"
        case .LoginTwitter:
            return "login/twitter"
        case .LoginGoogle:
            return "login/google"
        case .Logout:
            return "logout"
        default:
            return ""
        }
    }
}

enum APINews : Int, EndpointProtocol {
    
    case newsItem, newsItems
    
    func endpoint() -> String {
        
        switch self {
        case .newsItem:
            return "newsItem"
        default:
            return "newsItems"
        }
    }
}

enum APIMedia : Int, EndpointProtocol {
    
    case images
    
    func endpoint() -> String {
        switch self {
        case .images:
            return "url/site/images"
        default:
            return ""
        }
    }
}

struct ApiURL {
    
    var uri : EndpointProtocol
    var id : [String]
    
    func resolve() -> String {
        
        var arr : [AnyObject] = uri.endpoint().componentsSeparatedByString(":id")
        
        var resolved: String = ""
        if arr.count > 1 {
            for i in 0..<arr.count-1 {
                var part : String = arr[i] as! String
                var _id : String = id[i]
                resolved = resolved + part + _id
            }
        }
        else {
            resolved = uri.endpoint()
        }
        
        return resolved
    }
}