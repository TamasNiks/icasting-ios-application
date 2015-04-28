//
//  Endpoints.swift
//  iCasting
//
//  Created by T. van Steenoven on 08-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

internal struct Host {
    static let API : String = "api-demo.icasting.net"
    static let Media : String = "media-demo.icasting.net"
    static let APIVersion : String = "1"
}

protocol EndpointProtocol {
    func endpoint() -> String
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

enum APINews : EndpointProtocol {
    
    case NewsItems, NewsItem(String), TestItemIDresourceIDlala(String, String)
    
    func endpoint() -> String {
        
        switch self {
        case .NewsItems:
            return "newsItems"
        case .NewsItem(let id):
            return "newsItem/\(id)"
        case .TestItemIDresourceIDlala(let itemID, let resourceID):
            return "testItem/:part/resource/:part/lala"
        }
    }
    
    var value: String {
        get {return ICURL.createURL(self)}
    }
}


enum APIMedia : EndpointProtocol {
    
    case Image(String), ImageWithSize(String, String)
    
    func endpoint() -> String {
        switch self {
        case .Image(let id):
            return "site/images/\(id)"
        case .ImageWithSize(let id, let size):
            return "site/images/\(id)/\(size)"
        }
    }
    
    var value: String {
        get {return ICURL.createURL(self)}
    }
}

enum APIMatch : Int, EndpointProtocol {
    
    case MatchCards
    
    func endpoint() -> String {
        
        switch self {
        case .MatchCards:
            return "matchCards"
        }
    }
    
    var value: String { return ICURL.createURL(self) }
    
}

internal struct ApiURL {
    
    var uri : EndpointProtocol
    var insert : [String]
    
    func resolve() -> String {
        
        var fragments : [AnyObject] = uri.endpoint().componentsSeparatedByString(":part")
        
        var resolved: String = ""
        
        var fc : Int = fragments.count
        var ic : Int = insert.count
        
        if fc > 1 {
            for i in 0..<fc {
                var part : String = fragments[i] as! String
                
                var _insert : String = i < ic ? insert[i] : String()

                resolved = resolved + part + _insert
            }
        }
        else {
            resolved = uri.endpoint()
        }
        
        println(resolved)
        return resolved
    }
}
