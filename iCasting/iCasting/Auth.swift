//
//  Auth.swift
//  iCasting
//
//  Created by Tim van Steenoven on 30/04/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

struct Credentials {
    var email : String = ""// = "tim.van.steenoven@icasting.com"
    var password : String = ""// = "test"
}

struct Authentication {
    
    static let TOKEN_KEY: String = "access_token"
    static let USERID_KEY: String = "user_id"
    
    private var _user_id : String? // = "551d58a226042f74fb745533"
    private var _access_token: String? //="551d58a226042f74fb745533$YENvtqK2Eis3oKCG6vo76IgilplRXFO9h+LMKT1HdRo="
    
    private func saveAuthentication() {
        println("Token will be saved")
        NSUserDefaults.standardUserDefaults().setObject(_access_token, forKey: Authentication.TOKEN_KEY)
        NSUserDefaults.standardUserDefaults().setObject(_user_id, forKey: Authentication.USERID_KEY)
        //NSUserDefaults.standardUserDefaults().synchronize()
    }

    private mutating func clearAuthentication() {
        _user_id = nil
        _access_token = nil
        saveAuthentication()
        println("Authentication successfully cleared")
    }
    
    var access_token : String? {

        var value: String? = NSUserDefaults.standardUserDefaults().objectForKey(Authentication.TOKEN_KEY) as? String
        println("Token from NSuserDefaults: " + (value ?? "No token set"))
        return value
    }
    
    var user_id : String? {

        var value: String? = NSUserDefaults.standardUserDefaults().objectForKey(Authentication.USERID_KEY) as? String
        println("UserID from NSuserDefaults: " + (value ?? "No userid set"))
        return value
    }
    

}

typealias LoginClosure = RequestClosure

class Auth {
    
    static var auth: Authentication = Authentication() {
        willSet {
            newValue.saveAuthentication()
        }
    }
    
    func login(credentials: Credentials, callBack: LoginClosure) {
        
        LoginRequest(credentials: credentials).execute { errors -> () in

            if let errors = errors {
                callBack(failure: errors)
                return
            }
            
            UserRequest().execute { errors -> () in

                if let errors = errors {
                    callBack(failure: errors)
                    return
                }
                
                CastingObjectRequest().execute { error -> () in
                 
                    println(User.sharedInstance)
                    callBack(failure: error)
                }
            }
        }
    }
    
    
    func logout(callBack: RequestClosure) {
        
        if let token = Auth.auth.access_token {
            
            var params : [String:String] = [Authentication.TOKEN_KEY:token]
            var req : NSURLRequest = (RequestFactory
                .request(.post) as? RequestHeaderProtocol)!
                .create(APIAuth.Logout, content: (insert: nil, params: params), withHeaders: ["Authorization":""])
            
            request(req).responseJSON(completionHandler: { (request, response, json, error) -> Void in
               
                if let error = error {
                    let error: ICErrorInfo? = ICError(error: error).getErrors()
                    callBack(failure: error)
                }
                
                if let json: AnyObject = json {
                    
                    let json = JSON(json)
                    let errors: ICErrorInfo? = ICError(json: json).getErrors()
                    
                    if errors == nil {
                        //println(json)
                        Auth.auth.clearAuthentication()
                    }
                    
                    callBack(failure: errors)
                }
                
            })
        }
    }
    
}


protocol RequestCommand {
    func execute(callBack:LoginClosure)
}


class LoginRequest: RequestCommand {
    
    let credentials: Credentials
    init(credentials: Credentials) {
        self.credentials = credentials
    }
    
    func execute(callBack:LoginClosure) {
        
        // If there already exist an access_token AND user_id, skip the Basic login
        if let
        access_token = Auth.auth.access_token,
        user_id = Auth.auth.user_id
        {
            callBack(failure: nil)
            return
        }
        
        let url: String = APIAuth.Login.value
        var params : [String:AnyObject] = ["email":credentials.email, "password":credentials.password]
        request(.POST, url, parameters: params).responseJSON() { (request, response, json, error) in
            
            if(error != nil) {
                let errors: ICErrorInfo? = ICError(error: error).getErrors()
                callBack(failure: errors)
            }
            
            if let json: AnyObject = json {
                
                println("LoginRequest call success")
                
                let json = JSON(json)
                let errors: ICErrorInfo? = ICError(json: json).getErrors()
                
                if errors == nil {
                    
                    let user_id: String =  json["user_id"].stringValue
                    let token: String = json[Authentication.TOKEN_KEY].stringValue
                    let authentication: Authentication = Authentication(_user_id: user_id, _access_token: token)

                    println("Token from server: " + token)
                    Auth.auth = authentication
                    //Auth.auth.saveAuthentication()
                }
                
                callBack(failure: errors)
            }
        }
    }
}

class UserRequest: RequestCommand {
    func execute(callBack:LoginClosure) {
        (User.sharedInstance as ModelRequest).get { (failure) -> () in
            callBack(failure: failure)
        }
    }
}


class CastingObjectRequest: RequestCommand {
    func execute(callBack:LoginClosure) {
        (CastingObject() as ModelRequest).get { (failure) -> () in
            callBack(failure: failure)
        }
    }
}



