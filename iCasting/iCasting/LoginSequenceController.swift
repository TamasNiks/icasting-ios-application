//
//  LoginSequenceController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 25/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit


class LoginSequenceController: NSObject {
    
    dynamic var tryToLogin: Bool = false

    typealias LoginResultType = (success: ()->(), failure: (error: ICErrorInfo) -> ())

    
    func tryLoginSequence(result: LoginResultType) {
        
        println("LoginViewController: tryLoginSequence")
        
        // First check if the user still exists, whether through facebook or normal login
        if let passport = Auth.passport
        {
            // Because the user is still logged-in, we don't send credentials as a parameter
            startLoginSequence(nil, result: result)
        }
            // If the user doesn't have a passport authentication stored, check if Facebook is still logged in, if it is, logout, because the try to login depends totally on the accessToken and userID of iCasting. If it isn't there, the user should login manually, hence logout on facebook
        else {
            if let fbsdkCurrentAccessToken = FBSDKAccessToken.currentAccessToken() {
                FBSDKLoginManager().logOut()
            }
        }
    }


    func startLoginSequence(c: Credentials?, result: LoginResultType) {
        
        self.tryToLogin = true
        
        // Create a completionHandler which gets called after all the necessary requests are done. All the data is availabe to process completion requests
        let completionHandler: () -> () = {
            
            self.tryToLogin = false
            
            // Check if the user is client, because clients are not yet supported, show an alert and log out
            if User.sharedInstance.isClient {
                
                result.failure(error: ICError.CustomErrorInfoType.ClientNotSupportedError.errorInfo)
                
                Auth.logout { failure in println(failure) }
                
                return
            }
            
            // Try to register the device
            
            // TODO: Check if user has enabled notifications before registering
            //                PushNotificationDevice.sharedInstance.addDeviceForRemoteNotifications() { error in
            //                    if let error = error {
            //                        println("DEBUG: LoginSequenceController: Registering device failure - \(error)")
            //                    }
            //                }
            
            // The app will register a device when it contains a device token (push token)
            PushTokenHandshaker.sharedInstance.markToProceed()
            
            // Check if the user e-mail is verified, if not give feedback to the user. The user can proceed without verifing e-mail, but it cannot accept / reject matches
            if User.sharedInstance.mailIsVerified == false {
                
                result.failure(error: ICError.CustomErrorInfoType.EmailNotVerifiedError.errorInfo)
                
                return
            }
            
            result.success()
        }
        
        
        Auth.login(c) { error in
            
            // First do some error handling for the login request
            if let error = error {
                result.failure(error: error)
                return
            }
            
            // Do the following up HTTP requests to get the app data
            // Get general user information
            UserRequest().execute { error -> () in
                
                if let error = error {
                    result.failure(error: error)
                    return
                }
                
                // Get the casting object(s) from the user account
                CastingObjectRequest().execute { error -> () in
                    
                    if let error = error {
                        result.failure(error: error)
                        return
                    }
                    
                    println(User.sharedInstance)
                    completionHandler()
                }
            }
        }
    }
}