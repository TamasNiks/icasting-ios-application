//
//  EndpointFactory.swift
//  iCasting
//
//  Created by T. van Steenoven on 08-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

private typealias BuilderClosure = (URLBuilder) -> ()

private struct Host {
    static let API : String = "api-demo.icasting.net"
    static let Media : String = "media-demo.icasting.net"
}

protocol URLCommandProtocol {
    func execute(uri: EndpointProtocol, id: String?) -> NSURL
}


class URLSimpleFactory {

//    class func createURL(uri: EndpointProtocol, id: String?) -> NSURL {
//
//        let b : URLBuilder = URLBuilder {
//            $0.host = Host.API
//            $0.version = "/api/v1"
//            $0.endpoint = uri
//            $0.id = id
//        }
//        
//        let url : NSURL = URL(builder: b).nsurl
//        
//        return url
//    }
//    
//    class func createMediaURL(uri: EndpointProtocol, id: String) -> NSURL {
//        
//        let b : URLBuilder = URLBuilder {
//            $0.host = Host.Media
//            $0.endpoint = uri
//            $0.id = id
//            $0.uri.append("200x200")
//        }
//        
//        let url : NSURL = URL(builder: b).nsurl
//        
//        return url
//    }
    
    class func createURL(uri: EndpointProtocol, id:String?) -> NSURL {

        var command: URLCommandProtocol
        
        if let _uri = uri as? APIMedia {
            command = MediaURLCommand()
        }
        else {
            command = NormalURLCommand()
        }
        return command.execute(uri, id: id)
    }
    

}


extension URLSimpleFactory {
    
    class func createURL2(uri: EndpointProtocol, id: [String]?) -> NSURL {
        
        var sUri:String
        if let id = id {
            sUri = ApiURL(uri: uri, id: id).resolve()
        } else {
            sUri = uri.endpoint()
        }
        
        
        return NSURL()
        
    }
    
    
    
    
    
}

private class TestURLCommand : URLCommandProtocol {
    
    private func execute(uri: EndpointProtocol, id: String?) -> NSURL {
        let b : URLBuilder = URLBuilder {
            $0.host = Host.API
            $0.version = "/api/v1"
            $0.endpoint = uri
            $0.id = id
        }
        return URL(builder: b).nsurl
    }
}



private class NormalURLCommand : URLCommandProtocol {
    
    private func execute(uri: EndpointProtocol, id: String?) -> NSURL {
        let b : URLBuilder = URLBuilder {
            $0.host = Host.API
            $0.version = "/api/v1"
            $0.endpoint = uri
            $0.id = id
        }
        return URL(builder: b).nsurl
    }
}

private class MediaURLCommand : URLCommandProtocol {
    
    private func execute(uri: EndpointProtocol, id: String?) -> NSURL {
        let b : URLBuilder = URLBuilder {
            $0.host = Host.Media
            $0.endpoint = uri
            $0.id = id
            $0.uri.append("200x200")
        }
        return URL(builder: b).nsurl
    }
}

/* URL BUILDER */

private class URLBuilderTest {

    let scheme : String = "https"
    var host : String?
    var version : String?
    var endpoint : String?

    init(buildClosure: (URLBuilderTest) -> ()) {
        buildClosure(self)
    }
}

private class URLBuilder {

    let scheme : String = "https"
    var host : String?
    var version : String?
    var endpoint : EndpointProtocol?
    var id : String?
    var uri : [String] = [String]()
    
    init(buildClosure: BuilderClosure) {
        buildClosure(self)
    }
}

private struct URL {
    
    var scheme: String? = nil
    var host: String? = nil
    var version: String? = nil
    var endpoint: EndpointProtocol? = nil
    var id: String? = nil
    var uri: [String] = [String]()
    
    var nsurl: NSURL = NSURL()
    
    init(builder: URLBuilder) {

        self.scheme = builder.scheme
        self.host = builder.host
        self.version = builder.version
        self.endpoint = builder.endpoint
        self.id = builder.id
        self.uri = builder.uri
        
        func endpointNSURL() -> NSURL {
            
            var resolved : String = ""
            
            if let _version = self.version {
                resolved = _version
            }
            
            if let _endpoint = self.endpoint {
                resolved = "\(resolved)/\(_endpoint.endpoint())"
            }
            
            if let _id = self.id {
                resolved = "\(resolved)/\(_id)"
            }
            
            if self.uri.count > 0 {
                resolved = "\(resolved)/"+self.uri[0]
            }
            
            let url : NSURL = NSURL(
                scheme: scheme!,
                host: host,
                path: resolved)!
            
            return url
        }
        
        self.nsurl = endpointNSURL()
        println("api call:\(self.nsurl)")
        
    }

 }



