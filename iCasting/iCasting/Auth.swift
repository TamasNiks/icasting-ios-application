//
//  Auth.swift
//  iCasting
//
//  Created by Tim van Steenoven on 30/04/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

//enum LoginType {
//    case NormalLogin, FacebookLogin
//}

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
    
    private var _userID : String? // = "551d58a226042f74fb745533"
    private var _accessToken: String? //="551d58a226042f74fb745533$YENvtqK2Eis3oKCG6vo76IgilplRXFO9h+LMKT1HdRo="
    
    private static var onceTokenToLogAccessToken: dispatch_once_t = 0
    private static var onceTokenToLogUserID: dispatch_once_t = 0
    
    private func savePassport() {
        println("Passport update will be saved")
        // TODO: A better store to save this information is probably the keychain, this is where Facebook it's accessToken saves
        NSUserDefaults.standardUserDefaults().setObject(_accessToken, forKey: Passport.TOKEN_KEY)
        NSUserDefaults.standardUserDefaults().setObject(_userID, forKey: Passport.USERID_KEY)
    }

    private mutating func clearPassport() {
        _userID = nil
        _accessToken = nil
        savePassport()
        println("Passport successfully cleared")
    }
    
    var accessToken : String? {

        var value: String? = NSUserDefaults.standardUserDefaults().objectForKey(Passport.TOKEN_KEY) as? String
        
        dispatch_once(&Passport.onceTokenToLogAccessToken, { () -> Void in
            println("Access token from NSuserDefaults: " + (value ?? "No access token set"))
        })
        
        return value
    }
    
    var userID : String? {

        var value: String? = NSUserDefaults.standardUserDefaults().objectForKey(Passport.USERID_KEY) as? String
        
        dispatch_once(&Passport.onceTokenToLogUserID, { () -> Void in
            println("UserID from NSuserDefaults: " + (value ?? "No userid set"))
        })
        
        return value
    }
    

}

typealias LoginClosure = RequestClosure

class Auth {
    
    // Convenience getter to do the user id and access token check at once.
    static var passport: (userID: String, accessToken: String)? {
        if let
            accessToken = Auth._passport.accessToken,
            userID = Auth._passport.userID
        {
            return (userID: userID, accessToken: accessToken)
        }
        return nil
    }
    
    
    // If a new authentication construct is set, for example, if the login process has been succesfully finished
    private static var _passport: Passport = Passport() {
        willSet {
            newValue.savePassport()
        }
    }
}





extension Auth {
    
    
    static func login(credentials: Credentials?, callBack: LoginClosure) {

        LoginRequest(credentials: credentials).execute { failure in
            callBack(failure: failure)
        }
    }
    
    static func logout(callBack: RequestClosure) {
    
        // First deregister the device and then logout
        PushNotificationDevice.sharedInstance.removeDeviceForRemoteNotifications() { failure in
            
            if let failure = failure {
                println("DEBUG - Auth: removeDeviceForRemoteNotifications"+failure.description)
                callBack(failure: failure)
            }
        
            LogoutRequest().execute(callBack)
        }
    }
    
}





protocol RequestCommand {
    func execute(callBack: LoginClosure)
}


class LogoutRequest: RequestCommand {
    
    func execute(callBack: RequestClosure) {
        
        request(Router.Auth.Logout).responseJSON(completionHandler: { (request, response, json, error) -> Void in
            
            println("Auth: Logout request completed")
            
            var error: ICErrorInfo? = ICError(error: error).errorInfo
            
            if let json: AnyObject = json {
                
                error = ICError(json: JSON(json)).errorInfo
                
                if error == nil { Auth._passport.clearPassport() }
            }
            
            callBack(failure: error)
        })
    }
}


class LoginRequest: RequestCommand {
    
    //var loginType: LoginType = LoginType.NormalLogin
    let credentials: Credentials?
    
    init(credentials: Credentials?) {
        self.credentials = credentials
    }
    
    func execute(callBack: LoginClosure) {
        
        // If there already exist an accessToken AND userID set, skip the Basic login
        if let passport = Auth.passport {
            callBack(failure: nil)
            return
        }
        
        if let req = getLoginRequest() {
            
            request(req).responseJSON() { (request, response, json, error) in
                
                if let error = ICError(error: error).errorInfo {
                    callBack(failure: error)
                }
                
                if let json: AnyObject = json {
                    
                    let parsedJSON = JSON(json)
                    if let error: ICErrorInfo = ICError(json: parsedJSON).errorInfo {
                        
                        println(error)
                        callBack(failure: error)
                        
                    } else {
                        
                        let passport: Passport = Passport(
                            _userID:       parsedJSON[Passport.USERID_KEY].string,
                            _accessToken:  parsedJSON[Passport.TOKEN_KEY].string)
                        
                        Auth._passport = passport
                        println(Auth.passport)
                        
                        callBack(failure: nil)
                    }
                }
            }
        }
        else {
            NSException(name: "LoginRequestException", reason: "This login is not yet supported, add it to the getLoginRequest method", userInfo: nil)
        }
    }
    
    private func getLoginRequest() -> Router.Auth? {
        
        var req: Router.Auth?
        
        if let credentials = self.credentials {
            
            if let c = credentials.userCredentials {
                req = Router.Auth.Login(["email" : c.email, "password" : c.password])
            }
            
            if let c = credentials.facebookCredentials {
                req = Router.Auth.LoginFacebook(["token" : c.userID])
            }
        }
        
        return req
    }
}