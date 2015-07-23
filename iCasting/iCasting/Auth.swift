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

struct Passport {
    
    static let TOKEN_KEY: String = "access_token"
    static let USERID_KEY: String = "user_id"
    
    private var _user_id : String? // = "551d58a226042f74fb745533"
    private var _access_token: String? //="551d58a226042f74fb745533$YENvtqK2Eis3oKCG6vo76IgilplRXFO9h+LMKT1HdRo="
    
    private func savePassport() {
        println("Passport will be saved")
        // TODO: A better store to save this information is probably the keychain, this is where Facebook it's access_token saves
        NSUserDefaults.standardUserDefaults().setObject(_access_token, forKey: Passport.TOKEN_KEY)
        NSUserDefaults.standardUserDefaults().setObject(_user_id, forKey: Passport.USERID_KEY)
    }

    private mutating func clearPassport() {
        _user_id = nil
        _access_token = nil
        savePassport()
        println("Passport successfully cleared")
    }
    
    var access_token : String? {

        var value: String? = NSUserDefaults.standardUserDefaults().objectForKey(Passport.TOKEN_KEY) as? String
        println("Access token from NSuserDefaults: " + (value ?? "No access token set"))
        return value
    }
    
    var user_id : String? {

        var value: String? = NSUserDefaults.standardUserDefaults().objectForKey(Passport.USERID_KEY) as? String
        println("UserID from NSuserDefaults: " + (value ?? "No userid set"))
        return value
    }
    

}

typealias LoginClosure = RequestClosure

class Auth {
    
    // If a new authentication construct is set, for example, if the login process has been succesfully finished
    private static var _passport: Passport = Passport() {
        willSet {
            newValue.savePassport()
        }
    }
    
    // Convenience getter to do the user id and access token check at once.
    static var passport: (user_id: String, access_token: String)? {
        if let
            access_token = Auth._passport.access_token,
            user_id = Auth._passport.user_id
        {
            return (user_id: user_id, access_token: access_token)
        }
        return nil
    }
    
    static func login(credentials: Credentials?, callBack: LoginClosure) {
        
        LoginRequest(credentials: credentials).execute { errors -> () in
            callBack(failure: errors)
        }
    }
    
    static func logout(callBack: RequestClosure) {
    
        // First deregister the device
        Push().deregisterDevice { failure in
            
            if let failure = failure {
                println("DEBUG: "+failure.description)
            }
        
            request(Router.Auth.Logout).responseJSON(completionHandler: { (request, response, json, error) -> Void in
                
                var error: ICErrorInfo? = ICError(error: error).getErrors()
                
                if let json: AnyObject = json {
                    
                    let json = JSON(json)
                    error = ICError(json: json).getErrors()
                    if error == nil {
                        Auth._passport.clearPassport()
                    }
                }
                
                callBack(failure: error)
            })
        }
    }
    
}



protocol RequestCommand {
    func execute(callBack:LoginClosure)
}


class LoginRequest: RequestCommand {
    
    var loginType: LoginType = LoginType.NormalLogin
    let credentials: Credentials?
    
    init(credentials: Credentials?) {
        self.credentials = credentials
    }
    
    func execute(callBack: LoginClosure) {
        
        // If there already exist an access_token AND user_id set, skip the Basic login
        if let passport = Auth.passport {
            callBack(failure: nil)
            return
        }
        
        // Depending on which login credentials are set (facebook or normal), get the specific credentials
        let rp = getParameters()
        
        request(.POST, rp.url, parameters: rp.params).responseJSON() { (request, response, json, error) in
            
            if let error = ICError(error: error).getErrors() {
                callBack(failure: error)
            }
            
            if let json: AnyObject = json {
                
                let parsedJSON = JSON(json)
                if let error: ICErrorInfo = ICError(json: parsedJSON).getErrors() {
                
                    println(error)
                    callBack(failure: error)
                    
                } else {

                    let passport: Passport = Passport(
                        _user_id:       parsedJSON[Passport.USERID_KEY].string,
                        _access_token:  parsedJSON[Passport.TOKEN_KEY].string)
                    
                    Auth._passport = passport
                    println(Auth.passport)
                    
                    callBack(failure: nil)
                }
            }
        }
    }
    
    // In the future there can be more than two login methods, think about a better more loosly coupled implementation to cope with these methods
    func getParameters() -> (url: URLStringConvertible, params: [String:AnyObject]) {
        
        // TODO: For a better flow, return nil if no params could be set.
        var url: URLStringConvertible = String()
        var params: [String:AnyObject] = [String:AnyObject]()
        
        if let credentials = self.credentials {
            if let c = credentials.userCredentials {
                url = Router.Auth.Login.url
                params = ["email" : c.email, "password" : c.password]
            }
            
            if let c = credentials.facebookCredentials {
                url = Router.Auth.LoginFacebook.url
                params = ["token" : c.userID]
            }
        }
        
        return (url: url, params: params)
    }
}