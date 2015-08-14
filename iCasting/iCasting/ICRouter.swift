//
//  ICRouter.swift
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

protocol EndpointParameterProtocol: EndpointProtocol {
    func addParameters(URLRequest: NSURLRequest) -> NSURLRequest
}

private let kPopulateKey: String = "populate[]"


enum Router {
    
    enum User: EndpointProtocol {
        
        case
        ReadUser(String),
        VerifyEmailUser(String)
        
        func endpoint() -> String {
            switch self {
            case .ReadUser(let id):
                return "user/\(id)"
            case .VerifyEmailUser(let id):
                return "verify/email/\(id)"
            }
        }
        
        var method: Method {
            switch self {
            case .ReadUser:
                return .GET
            case .VerifyEmailUser:
                return .POST
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
    
    
    
    
    
    enum Auth: EndpointParameterProtocol {
        
        case
        Login([String : AnyObject]),
        LoginFacebook([String : AnyObject]),
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
            .LoginFacebook,
            .Logout:
                return .POST
            case
            .LoginTwitter,
            .LoginGoogle:
                return .GET
            }
        }
        
        var url: URLStringConvertible { return ICURL.createURL(self) }
        
        var URLRequest: NSURLRequest {
            
            let mutableURLRequest = NSMutableURLRequest(URL: self.url as! NSURL)
            mutableURLRequest.HTTPMethod = self.method.rawValue
            mutableURLRequest.addAuthorizationHeaderField()
            return addParameters(mutableURLRequest)
        }
        
        internal func addParameters(URLRequest: NSURLRequest) -> NSURLRequest {
            
            let encoding = ParameterEncoding.JSON
            switch self {
            case .Login(let parameters):
                return encoding.encode(URLRequest, parameters: parameters).0
            case .LoginFacebook(let parameters):
                return encoding.encode(URLRequest, parameters: parameters).0
            default:
                return URLRequest
            }
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
    
    
    
    
    
    enum Match: EndpointParameterProtocol {
        
        case
        MatchCards,
        Match(String),
        MatchPopulateJobOwner(String),
        MatchesCastingObject(String),
        MatchesCastingObjectCards(String),
        MatchAcceptTalent(String),
        MatchRejectTalent(String),
        MatchConversation(String),
        MatchConversationToken(String),
        MatchRateClient(String, parameters: [String : AnyObject])
        
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
            case .MatchRateClient(let id, let parameters):
                return "match/\(id)/rateClient"
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
            MatchRejectTalent,
            MatchRateClient:
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
        
        internal func addParameters(URLRequest: NSURLRequest) -> NSURLRequest {
            
            switch self {
            case .MatchPopulateJobOwner:
                return ParameterEncoding.URL.encode(URLRequest, parameters: [kPopulateKey : "job.owner"]).0
            case .MatchRateClient(let id, let parameters):
                return ParameterEncoding.JSON.encode(URLRequest, parameters: parameters).0
            default:
                return URLRequest
            }
        }
    }
    
    
    
    
    
    enum Notifications: EndpointProtocol {
        
        case
        Notifications,
        NotificationsPage(Int),
        NotificationsLimit(Int)
        
        func endpoint() -> String {
            switch self {
            case .Notifications:
                return "notifications"
            case .NotificationsPage(let page):
                return "notifications?page=\(page)"
            case .NotificationsLimit(let limit):
                return "notifications?limit=\(limit)"
            }
        }
    
        var method: Method {
            switch self {
            case
            Notifications,
            NotificationsPage,
            NotificationsLimit:
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
    
    
    
    
    
    enum Push: EndpointParameterProtocol {
        
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
        
        internal func addParameters(URLRequest: NSURLRequest) -> NSURLRequest {
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