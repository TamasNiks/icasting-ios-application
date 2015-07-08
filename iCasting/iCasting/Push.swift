//
//  Push.swift
//  iCasting
//
//  Created by Tim van Steenoven on 29/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


protocol PushProtocol {
    func registerDevice(callBack: RequestClosure)
    func deregisterDevice(callBack: RequestClosure)
}


struct PushResponse {

    private static let Key: String = "DeviceID" // ID from the API

    private var _deviceID: String?
    
    func save() {
        NSUserDefaults.standardUserDefaults().setObject(_deviceID, forKey: PushResponse.Key)
    }
    
    var deviceID: String? {
        return NSUserDefaults.standardUserDefaults().objectForKey(PushResponse.Key) as? String
    }
}


struct DeviceToken {

    private static let Old: String = "DeviceToken" // Token from the APNs
    private static let New: String = "NewDeviceToken" // Possible new token from the APNs

    static var token: String? {
        willSet {
            if newValue != DeviceToken.token {
                NSUserDefaults.standardUserDefaults().setObject(token, forKey: DeviceToken.New)
            }
        }
    }
    
    private static var oldToken: String? {
        return NSUserDefaults.standardUserDefaults().objectForKey(DeviceToken.Old) as? String
    }
    
    // A more convenient way of knowing whether the new token already exist or not.
    static var updatedToken: Bool {
        if let oldToken = DeviceToken.oldToken {
            return DeviceToken.token == oldToken ? false : true
        }
        return true
    }
    
    // Save the current token as an old token
    static func saveNewToken() {
        NSUserDefaults.standardUserDefaults().setObject(DeviceToken.token, forKey: DeviceToken.Old)
    }
}


class Push: PushProtocol {
    
    static var config: PushResponse? {
        willSet {
            newValue?.save()
        }
    }
    
    func registerDevice(callBack: RequestClosure) {
        
        if DeviceToken.updatedToken || Push.config?.deviceID == nil {
            println("Push: Update in device token or device id == nil")
            requestForRegisterDevice(callBack)
        } else {
            println("Push: No update in device token")
        }
    }
    
    private func requestForRegisterDevice(callBack: RequestClosure) {
        
        let url = APIPush.Device.value
        
        if let parameters: [String : AnyObject] = getParameters() {
            
            // Because the parameters will be encoded to an JSON object, alomfire will automatically set the Content-Type to application/json
            request(.POST, url, parameters: parameters, encoding: ParameterEncoding.JSON).responseJSON() { (request, response, json, error) -> Void in
                
                // Network or general errors?
                if let errors = ICError(error: error).getErrors() {
                    callBack(failure: errors)
                }
                
                // No network errors, extract json
                if let _json: AnyObject = json {
                    
                    let parsedJSON = JSON(_json)
                    
                    // API Errors?
                    if let errors = ICError(json: parsedJSON).getErrors() {
                        println(errors)
                        callBack(failure: errors)
                        return
                    }
                    
                    println(parsedJSON)
                    self.mapResponse(parsedJSON)
                    DeviceToken.saveNewToken()
                    callBack(failure: nil)
                }
            }
        }
        else {
            println("Push: Parameters could not be set for registering device")
        }
    }
    
    
    func deregisterDevice(callBack: RequestClosure) {
        
    
    }
    
    
    func patchDevice(callBack: RequestClosure) {
        
        
    }

    
    private func getParameters() -> [String : AnyObject]? {
    
        if let passport = Auth.passport {
            
            let device_token: String = DeviceToken.token ?? ""
            
            var parameters: [String: AnyObject] = [String: AnyObject]()
            
            parameters["access_token"]  = passport.access_token
            parameters["application"]   = "ios"
            parameters["user"]          = passport.user_id
            
            var pushNotifications = [String: AnyObject]()
            pushNotifications["key"] = device_token
            pushNotifications["enabled"] = true
            
            parameters["pushNotifications"] = pushNotifications
            
            return parameters
        }

        return nil
    }
    
    
    private func mapResponse(json: JSON) {
    
        Push.config = PushResponse(_deviceID: json["_id"].stringValue)
    }
 
}