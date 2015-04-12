//
//  News.swift
//  iCasting
//
//  Created by T. van Steenoven on 09-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

class News {
    
    let sessionManager : SessionManager = SessionManager.sharedInstance()
    
    init() {
        
    }
    
    func get(callBack: RequestClosure) {
        
        var requestType : RequestProtocol = RequestFactory.requestType(Method.get)!
        var request = requestType.request(APINews.newsItems, content: (id: nil, body: nil))
        sessionManager.request(request, callbackClosure: callBack)
        
    }
    
    func item(id: NSString, callBack : RequestClosure) {
        
        var requestType : RequestProtocol = RequestFactory.requestType(Method.get)!
        var request = requestType.request(APINews.newsItem, content: (id: id as String, body: nil))
        sessionManager.request(request, callbackClosure: callBack)
        
    }
    
    func image(id : NSString, callBack : RequestClosure) {
        
        
        
    }
    
    
}