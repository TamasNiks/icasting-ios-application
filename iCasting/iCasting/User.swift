//
//  Model.swift
//  iCasting
//
//  Created by T. van Steenoven on 08-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

class User {

    static let sharedInstance : User = User()
    
    var id : String? = "551d58a226042f74fb745533"
    var access_token : String?
    var email : String? = ""
    var password : String? = ""
    
    
//    var access_token : String {
//        get { return "551d58a226042f74fb745533$FRqek0Bl9z70vkiAOgX9EkrQw25zu3jD0cNek5/gpqs=" }
//    }

    func login(email: String, password: String) {
        
        self.email = email
        self.password = password
        
        var params : [String:String] = ["email":email, "password":password]
        var requestType : RequestProtocol = RequestFactory.requestType(Method.post)!
        var request = requestType.request(APIAuth.Login, content:(insert: nil, params: params))

        SessionManager.sharedInstance.request(request) { result in
            
            if let data: AnyObject = result.success {
                self.access_token = data["access_token"] as? String
                println("Access token: ")
                println(self.access_token)
            } else if let data:AnyObject = result.success {
                println("ERROR")
            }
        }
        
    }
    
    func logout() {
        
        if let token = self.access_token {
            println("logout token: ")
            println(token)
            var params : [String:String] = ["access_token":token]
            var type : RequestHeaderProtocol = (RequestFactory.requestType(Method.post) as? RequestHeaderProtocol)!
            var request = type.request(
                APIAuth.Logout,
                content: (insert: nil, params: params),
                withHeaders: ["Authorization":""])
            
            SessionManager.sharedInstance.request(request) { result in
                if let data: AnyObject = result.success {
                    println(data)
                    self.access_token = nil
                }
            }
        }
        
    }
    
}