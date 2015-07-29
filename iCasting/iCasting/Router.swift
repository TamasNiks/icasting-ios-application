//
//  Router.swift
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

protocol EndpointProtocol: URLRequestConvertible {
    func endpoint() -> String
    var method: Method { get }
    var url: URLStringConvertible { get }
}

let POPULATE_KEY: String = "populate[]"


enum Router {
    
    enum User: EndpointProtocol {
        
        case
        ReadUser(String)
        
        func endpoint() -> String {
            switch self {
            case .ReadUser(let id):
                return "user/\(id)"
            }
        }
        
        var method: Method {
            switch self {
            case .ReadUser:
                return .GET
            }
        }
        
        var url: URLStringConvertible { return ICURL.createURL(self) }
        
        var URLRequest: NSURLRequest {
            
            //API.test()
            
            let mutableURLRequest = NSMutableURLRequest(URL: self.url as! NSURL)
            mutableURLRequest.HTTPMethod = self.method.rawValue
            mutableURLRequest.addAuthorizationHeaderField()
            return mutableURLRequest
        }
    }
    

    
    
    
    enum CastingObject: EndpointProtocol {
        
        case
        ReadUserCastingObjectsSummary(String),
        ReadUserCastingObjects(String),
        ReadCastingObject(String)
        
        func endpoint() -> String {
            
            switch self {
            case .ReadUserCastingObjectsSummary(let userid):
                return "user/\(userid)/castingObjects/summary"
            case .ReadUserCastingObjects(let userid):
                return "user/\(userid)/castingObjects"
            case .ReadCastingObject(let id):
                return "castingObject/\(id)"
            }
        }
        
        var method: Method {
            switch self {
            case
            .ReadUserCastingObjectsSummary,
            .ReadUserCastingObjects,
            .ReadCastingObject:
                return .GET
            }
        }
        
        var url: URLStringConvertible { return ICURL.createURL(self) }
        
        var URLRequest: NSURLRequest {
            
            let mutableURLRequest = NSMutableURLRequest(URL: self.url as! NSURL)
            mutableURLRequest.HTTPMethod = self.method.rawValue
            mutableURLRequest.addAuthorizationHeaderField()
            return mutableURLRequest
        }

    }
    
    
    
    
    
    enum Auth: EndpointProtocol {
        
        case
        Login,
        LoginFacebook,
        LoginTwitter,
        LoginGoogle,
        Logout
        
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
            }
        }
        
        var method: Method {
            switch self {
            case
            .Login,
            .Logout:
                return .POST
            case
            .LoginFacebook,
            .LoginTwitter,
            .LoginGoogle:
                return .GET
            }
        }
        
        var url: URLStringConvertible { return ICURL.createURL(self) }
        
        var URLRequest: NSURLRequest {
            
            let mutableURLRequest = NSMutableURLRequest(URL: self.url as! NSURL)
            mutableURLRequest.HTTPMethod = self.method.rawValue
            
            if self == Auth.Logout {
                mutableURLRequest.setValue("", forHTTPHeaderField: "Authorization")
            }
            
            mutableURLRequest.addAuthorizationHeaderField()
            return mutableURLRequest
        }
    }
    
    
    
    
    
    enum News : EndpointProtocol {
        
        case
        NewsItems,
        NewsItem(String),
        TestItemIDresourceIDlala(String, String)
        
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
        
        var method: Method {
            switch self {
            case
            NewsItems,
            NewsItem,
            TestItemIDresourceIDlala:
                return .GET
            }
        }
        
        var url: URLStringConvertible { return ICURL.createURL(self) }
        
        var URLRequest: NSURLRequest {

            let mutableURLRequest = NSMutableURLRequest(URL: self.url as! NSURL)
            mutableURLRequest.HTTPMethod = self.method.rawValue
            //mutableURLRequest.addAuthorizationHeaderField()
            return mutableURLRequest
        }
    }
    
    
    
    
    
    enum Media: EndpointProtocol {
        
        case
        Image(String),
        ImageWithSize(String, String)
        
        func endpoint() -> String {
            switch self {
            case .Image(let id):
                return "site/images/\(id)"
            case .ImageWithSize(let id, let size):
                return "site/images/\(id)/\(size)"
            }
        }
        
        var method: Method {
            switch self {
            case
            Image,
            ImageWithSize:
                return .GET
            }
        }
        
        var url: URLStringConvertible { return ICURL.createURL(self) }
        
        var URLRequest: NSURLRequest {
            
            let mutableURLRequest = NSMutableURLRequest(URL: self.url as! NSURL)
            mutableURLRequest.HTTPMethod = self.method.rawValue
            mutableURLRequest.addAuthorizationHeaderField()
            return mutableURLRequest
        }
    }
    
    
    
    
    
    enum Match: EndpointProtocol {
        
        case
        MatchCards,
        Match(String),
        MatchPopulateJobOwner(String),
        MatchesCastingObject(String),
        MatchesCastingObjectCards(String),
        MatchAcceptTalent(String),
        MatchRejectTalent(String),
        MatchConversation(String),
        MatchConversationToken(String)
        
        func endpoint() -> String {
            switch self {
            case .Match(let id):
                return "match/\(id)"
            case .MatchPopulateJobOwner(let id):
                return "match/\(id)"
            case .MatchCards:
                return "matchCards"
            case .MatchesCastingObject(let id):
                return "castingObject/\(id)/matches"
            case .MatchesCastingObjectCards(let id):
                return "castingObject/\(id)/matches/cards"
            case .MatchAcceptTalent(let id):
                return "match/\(id)/acceptTalent"
            case .MatchRejectTalent(let id):
                return "match/\(id)/rejectTalent"
            case .MatchConversation(let id):
                return "match/\(id)/conversation"
            case .MatchConversationToken(let id):
                return "match/\(id)/conversationToken"
            }
        }
        
        var method: Method {
            switch self {
            case
            MatchCards,
            Match,
            MatchPopulateJobOwner,
            MatchesCastingObject,
            MatchesCastingObjectCards,
            MatchConversation,
            MatchConversationToken:
                return .GET
            case
            MatchAcceptTalent,
            MatchRejectTalent:
                return .POST

            }
        }
        
        var url: URLStringConvertible { return ICURL.createURL(self) }
        
        var URLRequest: NSURLRequest {
            
            let mutableURLRequest = NSMutableURLRequest(URL: self.url as! NSURL)
            mutableURLRequest.HTTPMethod = self.method.rawValue
            mutableURLRequest.addAuthorizationHeaderField()
            return addParameters(mutableURLRequest)
        }
        
        private func addParameters(URLRequest: NSURLRequest) -> NSURLRequest {
            
            switch self {
            case .MatchPopulateJobOwner:
                return ParameterEncoding.URL.encode(URLRequest, parameters: [POPULATE_KEY : "job.owner"]).0
            default:
                return URLRequest
            }
        }
    }
    
    
    
    
    
    enum Notifications: EndpointProtocol {
        
        case
        Notifications
        
        func endpoint() -> String {
            switch self {
            case .Notifications:
                return "notifications"
            }
        }
    
        var method: Method {
            switch self {
            case
            Notifications:
                return .GET
            }
        }
        
        var url: URLStringConvertible { return ICURL.createURL(self) }
        
        var URLRequest: NSURLRequest {
            
            let mutableURLRequest = NSMutableURLRequest(URL: self.url as! NSURL)
            mutableURLRequest.HTTPMethod = self.method.rawValue
            mutableURLRequest.addAuthorizationHeaderField()
            return mutableURLRequest
        }
    }
    
    
    
    
    
    enum Push: EndpointProtocol {
        
        case
        Device(parameters: [String : AnyObject]),
        DeviceID(String, parameters: [String : AnyObject])
        
        func endpoint() -> String {
            
            switch self {
            case .Device:
                return "device"
            case .DeviceID(let id, let parameters):
                return "device/\(id)"
                
            }
        }
        
        var method: Method {
            switch self {
            case .Device:
                return .POST
            case .DeviceID:
                return .PATCH
            }
        }
        
        var url: URLStringConvertible { return ICURL.createURL(self) }
        
        var URLRequest: NSURLRequest {
            
            let mutableURLRequest = NSMutableURLRequest(URL: self.url as! NSURL)
            mutableURLRequest.HTTPMethod = self.method.rawValue
            mutableURLRequest.addAuthorizationHeaderField()
            
            return addParameters(mutableURLRequest)
        }
        
        private func addParameters(URLRequest: NSURLRequest) -> NSURLRequest {
            let encoding = ParameterEncoding.JSON
            switch self {
            case .Device(let parameters):
                return encoding.encode(URLRequest, parameters: parameters).0
            case .DeviceID(let id, let parameters):
                return encoding.encode(URLRequest, parameters: parameters).0
            default:
                return URLRequest
            }
        }
        
    }
    
}