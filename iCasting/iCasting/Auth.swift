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
    var user_id : String = ""// = "551d58a226042f74fb745533"
    var access_token : String? // = "551d58a226042f74fb745533$YENvtqK2Eis3oKCG6vo76IgilplRXFO9h+LMKT1HdRo="
}

typealias LoginClosure = RequestClosure

class Auth {
    
    static var auth: Authentication = Authentication()
    
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
                
                CastingObjectRequest().execute { errors -> () in
                 

                    self.printResults()
                    callBack(failure: errors)
                    
//                    self.logout({ (result) -> () in
//                        
//                    })
                }
            }
        }
    }
    
    
    func logout(callBack: RequestClosure) {
        
        //TODO: Change logout with new HTTP system

        if let token = Auth.auth.access_token {
            
            println("logout token: ")
            println(token)
            
            var params : [String:String] = ["access_token":token]
            var request : NSURLRequest = (RequestFactory
                .request(.post) as? RequestHeaderProtocol)!
                .create(APIAuth.Logout, content: (insert: nil, params: params),withHeaders: ["Authorization":""])
            
            SessionManager.sharedInstance.request(request) { result in
                if let data: AnyObject = result.success {
                    println(data)
                    Auth.auth.access_token = nil
                }
                
                callBack(failure: ICError(error: result.failure).getErrors())
            }
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
        
        let url: String = APIUser.User(Auth.auth.user_id).value
        var params: [String : AnyObject] = ["access_token":Auth.auth.access_token!]
        request(.GET, url, parameters: params).responseJSON() { (request, response, json, error) in
            
            if(error != nil) {
                NSLog("Error: \(error)")
                println(request)
                println(response)
            }
            
            if let json: AnyObject = json {
                println("UserRequest call success")
                let json = JSON(json)
                let errors: ICErrorInfo? = ICError(json: json).getErrors()
                
                if errors == nil {
                    User.sharedInstance.displayName = json["name"]["display"].string
                    User.sharedInstance.credits = json["credits"]["total"].number!
                    User.sharedInstance.avatar = json["avatar"]["thumb"].string
                    User.sharedInstance.roles = json["roles"].array
                }
                
                callBack(failure: errors)
            }
        }
    }
}


class CastingObjectRequest: RequestCommand {
    
    func execute(callBack:LoginClosure) {
        
        let url: String = APICastingObject.UserCastingObject(Auth.auth.user_id).value
        var params: [String : AnyObject] = ["access_token":Auth.auth.access_token!]
        request(.GET, url, parameters: params).responseJSON() { (request, response, json, error) in
            
            if (error != nil) {
                NSLog("Error: \(error)")
                println(request)
                println(response)
            }
            
            if let json: AnyObject = json {
                println("CastingObjectRequest call success")
                let json = JSON(json)
                
                let errors: ICErrorInfo? = ICError(json: json).getErrors()
                
                if errors == nil {
                    var castingObjectIDs:[String] = [String]()
                    for (index: String, subJSON: JSON) in json {
                        let id: String = subJSON["id"].stringValue
                        castingObjectIDs.append(id)
                    }
                    
                    User.sharedInstance.castingObjectIDs = castingObjectIDs
                    User.sharedInstance.setCastingObject(0)
                }
                
                callBack(failure:errors)
            }
            
        }
        
    }
    
}



