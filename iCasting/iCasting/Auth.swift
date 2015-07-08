//
//  Auth.swift
//  iCasting
//
//  Created by Tim van Steenoven on 30/04/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

enum LoginType {
    case NormalLogin, FacebookLogin
}

typealias Credentials = AppCredentials

//-----------------------------
// For every new login method, create an credentials structure and add it to the AppCredentials structure. Use this AppCredentials struct to check which one is set in the LoginRequest class from where follow up actions are decided.
class AppCredentials {
    var userCredentials: UserCredentials?
    var facebookCredentials: FacebookCredentials?
}

struct UserCredentials {
    var email : String = ""// = "tim.van.steenoven@icasting.com"
    var password : String = ""// = "test"
}

struct FacebookCredentials {
    var userID : String
}
//-----------------------------

struct Authentication {
    
    static let TOKEN_KEY: String = "access_token"
    static let USERID_KEY: String = "user_id"
    
    private var _user_id : String? // = "551d58a226042f74fb745533"
    private var _access_token: String? //="551d58a226042f74fb745533$YENvtqK2Eis3oKCG6vo76IgilplRXFO9h+LMKT1HdRo="
    
    private func saveAuthentication() {
        println("Authentication will be saved")
        // TODO: A better store to save this information is probably the keychain, this is where Facebook it's access_token saves
        NSUserDefaults.standardUserDefaults().setObject(_access_token, forKey: Authentication.TOKEN_KEY)
        NSUserDefaults.standardUserDefaults().setObject(_user_id, forKey: Authentication.USERID_KEY)
    }

    private mutating func clearAuthentication() {
        _user_id = nil
        _access_token = nil
        saveAuthentication()
        println("Authentication successfully cleared")
    }
    
    var access_token : String? {

        var value: String? = NSUserDefaults.standardUserDefaults().objectForKey(Authentication.TOKEN_KEY) as? String
        println("Access token from NSuserDefaults: " + (value ?? "No access token set"))
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
    
    // If a new authentication construct is set, for example, if the login process has been succesfully finished
    static var auth: Authentication = Authentication() {
        willSet {
            newValue.saveAuthentication()
        }
    }
    
    // Convenience getter to do the user id and access token check at once.
    static var passport: (user_id: String, access_token: String)? {
        if let
            access_token = Auth.auth.access_token,
            user_id = Auth.auth.user_id
        {
            return (user_id: user_id, access_token: access_token)
        }
        return nil
    }
    
    func login(credentials: Credentials, callBack: LoginClosure) {
        
        LoginRequest(credentials: credentials).execute { errors -> () in

            if let errors = errors {
                callBack(failure: errors)
                return
            }
            
            // Get general user information
            UserRequest().execute { errors -> () in

                if let errors = errors {
                    callBack(failure: errors)
                    return
                }
                
                // Get the casting object(s) from the user account
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
    
    var loginType: LoginType = LoginType.NormalLogin
    let credentials: Credentials
    
    init(credentials: Credentials) {
        self.credentials = credentials
    }
    
    func execute(callBack: LoginClosure) {
        
        // If there already exist an access_token AND user_id set, skip the Basic login
        if let passport = Auth.passport {
            callBack(failure: nil)
            return
        }
        
        // Depending on which login credentials are set (facebook or normal), get the specific credentials
        let rp = getRequestProperties()
        
        request(.POST, rp.url, parameters: rp.params).responseJSON() { (request, response, json, error) in
            
            if let error = error {
                let errors: ICErrorInfo? = ICError(error: error).getErrors()
                callBack(failure: errors)
            }
            
            if let json: AnyObject = json {
                
                println("LoginRequest call success")
                let json = JSON(json)
                let errors: ICErrorInfo? = ICError(json: json).getErrors()
                
                // Errors,
                if errors == nil {

                    let authentication: Authentication = Authentication(
                        _user_id:       json[Authentication.USERID_KEY].string,
                        _access_token:  json[Authentication.TOKEN_KEY].string)

                    Auth.auth = authentication
                }
                
                callBack(failure: errors)
            }
        }
    }
    
    // In the future there can be more than two login methods, think about a better more loosly coupled implementation to cope with these methods
    func getRequestProperties() -> (url:String, params:[String:AnyObject]) {
        
        // TODO: For a better flow, return nil if no params could be set.
        var url: String = String()
        var params: [String:AnyObject] = [String:AnyObject]()
        
        if let c = credentials.userCredentials {
            url = APIAuth.Login.value
            params = ["email" : c.email, "password" : c.password]
        }
        
        if let c = credentials.facebookCredentials {
            url = APIAuth.LoginFacebook.value
            params = ["token" : c.userID]
        }
        return (url: url, params: params)
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



