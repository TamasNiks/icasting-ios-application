//
//  Model.swift
//  iCasting
//
//  Created by T. van Steenoven on 08-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

struct Credentials {
    var email : String = "tim.van.steenoven@icasting.com"
    var password : String = "test"
}

struct Authentication {
    var id : String = "551d58a226042f74fb745533"
    var access_token : String? = "551d58a226042f74fb745533$c5YojiozAZ24r0R9hLOxLi5MIFz7a8yShNJO9a51HT4="
}

//public struct

class User {

    static let sharedInstance : User = User()
    
    private var _auth: Authentication = Authentication()
    var auth: Authentication { return self._auth }
    
    var credentials: Credentials = Credentials()
    
    
    func login(credentials: Credentials, callBack: RequestClosure) {
        
        var params : [String:String] = ["email":credentials.email, "password":credentials.password]
        
        var request : NSURLRequest = RequestFactory
            .request(.post)
            .create(APIAuth.Login, content:(insert: nil, params: params))

        SessionManager.sharedInstance.request(request) { result in
            
            if let data: AnyObject = result.success {

                self._auth = Authentication(
                    id: (data["id"] as? String)!,
                    access_token: (data["access_token"] as? String)!)
                self.credentials = credentials
                
                println("Access token: ")
                println(self.auth.access_token)
            }
            
            callBack(result)
        }
        
    }
    
    func logout(callBack: RequestClosure) {
        
        if let token = self.auth.access_token {
            println("logout token: ")
            println(token)
            var params : [String:String] = ["access_token":token]

            var request : NSURLRequest = (RequestFactory
                .request(.post) as? RequestHeaderProtocol)!
                .create(APIAuth.Logout, content: (insert: nil, params: params),withHeaders: ["Authorization":""])
            
            SessionManager.sharedInstance.request(request) { result in
                if let data: AnyObject = result.success {
                    println(data)
                    self._auth.access_token = nil
                }
                
                callBack(result)
            }
        }
        
    }
    
}