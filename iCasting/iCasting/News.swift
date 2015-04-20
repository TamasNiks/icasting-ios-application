//
//  News.swift
//  iCasting
//
//  Created by T. van Steenoven on 09-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

protocol Model {
    
    func all (callBack: RequestClosure)
    func one (id: String, callBack: RequestClosure)
    
}

enum ImageSize {
    case Full, Thumbnail
    func toString() -> String {
        switch self {
            case .Full: return ""
            case .Thumbnail: return "200x200"
        }
    }
}

struct NewsKey {
    static let Summary: String = "summary"
    static let Body: String = "body"
    static let ImageID: String = "image"
    static let ID: String = "id"

}

class News : Model {
    
    let sessionManager : SessionManager = SessionManager.sharedInstance
    var newsItems : [AnyObject] = []
    
    /* Asks for all the items */
    func all(callBack: RequestClosure) {
        
        
        var request: NSURLRequest = RequestFactory.GET.create(APINews.newsItems, content:(insert: nil, params: nil))
        
        sessionManager.request(request) { result in
            
            if let success: AnyObject = result.success {
                self.newsItems = success as! [AnyObject]
            }
            
            callBack(result)
            
        }
    }
    
    /* Asks for one item for a given id */
    func one(id: String, callBack: RequestClosure) {
        
        var request: NSURLRequest = RequestFactory
            .request(.get)
            .create(APINews.newsItemWithID, content:(insert: [id], params: nil))

        sessionManager.request(request) { result in
            
            callBack(result)
   
        }
    }
}

extension News {
    
    func image(id: String, size: ImageSize, callBack : RequestClosure) {
        
        var request: NSURLRequest = RequestFactory
            .request(.get)
            .create(APIMedia.imageWithIDSize, content: (insert: [id, size.toString()], params: nil))
        
        sessionManager.request(request) { result in

            callBack(result)
            
        }
    }
}

