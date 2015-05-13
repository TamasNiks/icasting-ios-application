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
    
    let TOKEN_KEY: String = "access_token"
    
    var user_id : String = ""// = "551d58a226042f74fb745533"
    var access_token: String? {
        willSet {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: TOKEN_KEY)
            //="551d58a226042f74fb745533$YENvtqK2Eis3oKCG6vo76IgilplRXFO9h+LMKT1HdRo="
        }
    }
    
    private var _access_token : String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(TOKEN_KEY)
        }
    }
    
}

typealias LoginClosure = RequestClosure

class Auth {
    
    static var auth: Authentication = Authentication()
    
    func login(credentials: Credentials, callBack: LoginClosure) {
        
        if let access_token = Auth.auth._access_token {
            println("NSUserDefaults: \(access_token)")
            callBack(failure: nil)
            return
        }
        
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
                 
                    self.printResults()
                    callBack(failure: error)
                }
            }
        }
    }
    
    
    func logout(callBack: RequestClosure) {
        
        if let token = Auth.auth.access_token {
            
            var params : [String:String] = ["access_token":token]
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
                        println(json)
                        Auth.auth.access_token = nil
                    }
                    
                    callBack(failure: errors)
                }
                
            })
        }
    }
    
}

extension Auth {
    
    func printResults() {
        
        println("Login request sequence successfull")
        
        // TODO: Make User class Printable
        
//        println("castingObjectIDs")
//        println(User.sharedInstance.castingObjectIDs)
//        println("castingObjectID")
//        println(User.sharedInstance.castingObjectID)
//        println("credits")
//        println(User.sharedInstance.credits)
//        println("display")
//        println(User.sharedInstance.displayName)
//        println("avatar")
//        println(User.sharedInstance.avatar)
//        println("roles")
//        println(User.sharedInstance.roles)
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
                    let access_token: String = json["access_token"].stringValue
                    let authentication: Authentication = Authentication(user_id: user_id, access_token: access_token)
                    Auth.auth = authentication
                }
                
                callBack(failure: errors)
            }
        }
    }
}


class UserRequest: RequestCommand {
    func execute(callBack:LoginClosure) {
        User.sharedInstance.get { (failure) -> () in
            callBack(failure: failure)
        }
    }
}


class CastingObjectRequest: RequestCommand {
    func execute(callBack:LoginClosure) {
        CastingObject().get { (failure) -> () in
            callBack(failure: failure)
        }
    }
}



