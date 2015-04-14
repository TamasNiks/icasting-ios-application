//
//  News.swift
//  iCasting
//
//  Created by T. van Steenoven on 09-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

class News {
    
    let sessionManager : SessionManager = SessionManager.sharedInstance
    
//    init() {
//        
//    }
    
    // TODO: On the end, we want to encapsulate the making of the request, 
    // for the time being construct the requests in the Model
    
    func get(callBack: RequestClosure) {
        
        var requestType : RequestProtocol = RequestFactory.requestType(Method.get)!
        var request = requestType.request(APINews.newsItems, content:(insert: nil, params: nil))
        
        sessionManager.request(request) { result in
            
            callBack(result)
            
        }
    }
    
    func item(id: NSString, callBack : RequestClosure) {
        
        var requestType : RequestProtocol = RequestFactory.requestType(Method.get)!
        var request = requestType.request(APINews.newsItemID, content:(insert: [id as String], params: nil))
        
        sessionManager.request(request) { result in
            
            callBack(result)
            
        }
    }
    
    func image(id : NSString, callBack : RequestClosure) {
        
    }
    
    
}