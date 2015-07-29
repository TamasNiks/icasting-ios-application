//
//  LoginSequenceTemp.swift
//  iCasting
//
//  Created by Tim van Steenoven on 29/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

   /*
    private func tryLoginSequence() {
        
        println("LoginViewController: tryLoginSequence")
        
        // First check if the user still exists, whether through facebook or normal login
        if let passport = Auth.passport
        {
            // Because the user is still loged in, we give don't send credentials as parameters
            startLoginSequence(nil)
        }
        // If the user doesn't have an passport authentication stored, check if Facebook is still logged in, if it is, logout, because the try to login depends totally on the access_token and user_id of iCasting. If it isn't there, the user should login manually, hence logout on facebook
        else {
            if let fbsdkCurrentAccessToken = FBSDKAccessToken.currentAccessToken() {
                FBSDKLoginManager().logOut()
            }
        }
    }
    
    
    private func startLoginSequence(c: Credentials?) {
        
        self.tryToLogin = true

        Auth.login(c) { error in

            // First do some error handling from the login
            if let error = error {
                self.performErrorHandling(error)
                return
            }
            
            // Create a completionHandler which gets called after all the necessary requests are done
            let completionHandler: () -> () = {

                self.tryToLogin = false
                
                // Check if the user is client, because clients are not yet supported, show an alert and log out
                
                if User.sharedInstance.isClient {
                    
                    let title = NSLocalizedString("Announcement", comment: "Title of alert")
                    let message = NSLocalizedString("login.alert.client.notsupported", comment: "")
                    let av = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Ok")
                    av.show()
                    
                    Auth.logout({ (failure) -> () in println(failure) })
                    return
                }
                
                // Try to register the device
                
                PushNotificationDevice.sharedInstance.registerDevice() { error in
                    
                    if let error = error {
                        println("DEBUG: Registering failure - \(error)")
                    }
                }
                
                // If the user is not a client or talent, it is a manager, it will have casting objects, show the overview
                
                if User.sharedInstance.isManager {
                    
                    self.performSegueWithIdentifier(SegueIdentifier.CastingObjects, sender: self)
                    return
                }
                
                // If the user is talent, there's just one casting object, it has already been set in the model
                
                self.performSegueWithIdentifier(SegueIdentifier.Main, sender: self)
            }
            
            
            // Do the following up HTTP requests to get the app data
            
            // Get general user information
            UserRequest().execute { error -> () in
                
                if let error = error {
                    self.performErrorHandling(error)
                    return
                }
                
                // Get the casting object(s) from the user account
                CastingObjectRequest().execute { error -> () in
                    
                    if let error = error {
                        self.performErrorHandling(error)
                        return
                    }
                    
                    println(User.sharedInstance)
                    completionHandler()
                }
            }
        }
    }*/
