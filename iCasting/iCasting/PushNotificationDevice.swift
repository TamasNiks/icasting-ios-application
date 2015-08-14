//
//  PushNotificationDevice.swift
//  iCasting
//
//  Created by Tim van Steenoven on 29/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


protocol PushNotificationDeviceProtocol {
    
    func addDeviceForRemoteNotifications(callBack: RequestClosure)
    func removeDeviceForRemoteNotifications(callBack: RequestClosure)
}



protocol PushTokenLoginCheckObserver {
    
    func completedAddDeviceForRemoteNotificationWithFailure(failure: ICErrorInfo)
    
}

 class PushTokenLoginCheck {
    
    
    var delegate: PushTokenLoginCheckObserver?
    
    static let sharedInstance = PushTokenLoginCheck()
    
    var hasPushToken: Bool = false {
        willSet {
            checkToProceed()
        }
    }
    
    var hasAccessToken: Bool = false {
        willSet {
            checkToProceed()
        }
    }
    
    private func checkToProceed() {
        if hasPushToken && hasAccessToken {
         
            PushNotificationDevice.sharedInstance.addDeviceForRemoteNotifications() { possibleFailure in
                
                if let failure = possibleFailure {
                    self.delegate?.completedAddDeviceForRemoteNotificationWithFailure(failure)
                }
            }
            
        }
    }
    
    func addDeviceForRemoteNotifications(callBack: RequestClosure) {
        
    }
    

    
}


class PushNotificationDevice: PushNotificationDeviceProtocol {
    
    
    static let sharedInstance = PushNotificationDevice()
    
    // MARK: - Public interface
    
    func addDeviceForRemoteNotifications(callBack: RequestClosure) {
        
        // First check if there is a new token available, because with this new token, we need to register the device
        if PushToken.hasNewToken {
            
            // Because there is a new registration token available (or no older token exist), register the device on this token. Possible error: 
            // If you clear data and you get the same token from GCM, hasNewToken return true and thus fail since you can only register once. 
            // But in this case, there neither would be a patchID
            println("PushNotificationDevice: Update in device token: \(PushToken.hasNewToken)")
            registerDevice(callBack)
            return
        }
        
        // If there is not a new token been found, try to patch it
        if let patchID = PatchIDResponse.patchID {
            
            // No updated device token, enable the device on the current token
            println("PushNotificationDevice: patchID has been found: \(patchID)")
            patchDevice(true, callBack: callBack)
            return
        }
        
        // No patch ID is available, this can be a problem, because without a patch ID, a device cannot be enabled or disabled.
        println("CRITICAL DEBUG - PushNotificationDevice: PatchID doesn't exist, remove app and install it again")
    }
    
    
    func removeDeviceForRemoteNotifications(callBack: RequestClosure) {
        
        patchDevice(false, callBack: callBack)
    }
    
    
    // MARK: - Private methods

    private func patchDevice(enable: Bool, callBack: RequestClosure) {
        
        // A device can only be patched of there is a patchID available
        if let patchID = PatchIDResponse.patchID {
            
            // Parameters can only be created when authentication has been set, (after login) 
            // and when a Push token is available (should be set by the AppDelegate once Device Token retreived.
            if let parameters = getParametersForRegisterDevice(enabled: enable) {

                let req = Router.Push.DeviceID(patchID, parameters: parameters)
                request(req).responseJSON() { (request, response, json, error) -> Void in
                    
                    println("PushNotificationDevice - Patch device request completed")
                    
                    var error = ICError(error: error).errorInfo
                    
                    if let _json: AnyObject = json {
                        let parsedJSON = JSON(_json)
                        error = ICError(json: parsedJSON).errorInfo
                        println(parsedJSON)
                    }
                    
                    callBack(failure: error)
                }
                
            } else {
                
                println("DEBUG - PushNotificationDevice: Parameters could not be set for patching device, but the user should be able to continue anyway (authenticated? push token available?")
                callBack(failure: nil)
            }

        } else {
            
            println("DEBUG - PushNotificationDevice: patchID has not been set while trying to patching device: set enable to: \(enable), probably because of simulator")
            callBack(failure: nil)
        }
    }
    
    
    // For the first time register a device
    private func registerDevice(callBack: RequestClosure) {
        
        if let parameters = getParametersForRegisterDevice(enabled: true) {
            
            let req = Router.Push.Device(parameters: parameters)
            request(req).responseJSON() { (request, response, json, error) -> Void in
                
                println("PushNotificationDevice - Register device request completed")
                
                var error = ICError(error: error).errorInfo
                
                if let _json: AnyObject = json {
                    
                    let parsedJSON = JSON(_json)
                    error = ICError(json: parsedJSON).errorInfo
                    
                    if error == nil {
                        
                        println(parsedJSON)
                        println("for token to save: \(PushToken.token)")
                        
                        // Only if the device has been registered successfully, the push token can be saved locally
                        self.mapPatchIDResponse(parsedJSON)
                        PushToken.save()
                    }
                }
                
                callBack(failure: error)
            }
        }
        else {
            println("DEBUG - PushNotificationDevice: Parameters could not be set for registering device, probably because on simulator")
        }
    }
    
    
    private func mapPatchIDResponse(json: JSON) {
        if let id = json["_id"].string {
            PatchIDResponse(ID: id).save()
        } else {
            println("CRITICAL DEBUG - PushNotificationDevice: _id string does not exist in json, patch id not saved, cannot used for de/re register notifications")
        }
    }
    
    
    // The parameters are created for a register device HTTP request
    private func getParametersForRegisterDevice(#enabled: Bool) -> [String : AnyObject]? {
    
        if let passport = Auth.passport {

            if let token: String = PushToken.token {
                
                var parameters: [String: AnyObject] = [String: AnyObject]()
                parameters["application"]   = "android"
                parameters["user"]          = passport.userID
                
                var pushNotifications = [String: AnyObject]()
                pushNotifications["key"] = token
                pushNotifications["enabled"] = enabled
                
                parameters["pushNotification"] = pushNotifications
                
                return parameters
            }
            println("DEBUG - PushNotificationDevice: No PushToken set")
        }
        
        return nil
    }

    
    // The APNs can be converted to a string for further processing
    static func convertDeviceTokenToHexadecimal(deviceToken: NSData) -> String {
        
        var tokenAsMutableString = NSMutableString()
        
        var byteBuffer = [UInt8](count: deviceToken.length, repeatedValue: 0x00)
        deviceToken.getBytes(&byteBuffer, length: byteBuffer.count)
        
        for byte in byteBuffer {
            tokenAsMutableString.appendFormat("%02hhX", byte)
        }
        
        let tokenAsString = tokenAsMutableString as String
        println("Token = \(tokenAsString)")
        
        return tokenAsString
    }
    
}




// The PatchIDResponse will represent the Device ID given back by the server after device registration. The patchID is needed when doing a patch request for when the  registration token has been updated. This way, the registration token, coupled to a user, will be synchronised with the server provider (iCasting). The trouble is, when the device ID gets lost, there is no possibility to update a registration token with the iCasting server.

struct PatchIDResponse {
    
    private static let Key: String = "DeviceID" // ID key from the API
    
    private var ID: String
    
    func save() {
        NSUserDefaults.standardUserDefaults().setValue(ID, forKey: PatchIDResponse.Key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static var patchID: String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(PatchIDResponse.Key)
    }
}



// The PushToken will be used by the App delegate to store the token from APNs or GCM to use by the provider (iCasting) for (de)register a device.
struct PushToken {
    
    private static let Old: String = "PushToken" // Token from the APNs or GCM
    private static let New: String = "NewPushToken" // Possible new token from the APNs or GCM
    
    static var token: String? {
        set(newValue) {
            println("PushToken: Sets the new token from a Cloud Messenger Service")
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: PushToken.New)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(PushToken.New)
        }
    }
    
    static private var oldToken: String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(PushToken.Old)
    }
    
    // Save the current token as an old token
    static private func save() {
        NSUserDefaults.standardUserDefaults().setValue(PushToken.token, forKey: PushToken.Old)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // Remove the old token
    static private func clear() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(PushToken.Old)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // A more convenient way of knowing whether the new token already exist or not. If a new token exist, it should be updated
    static private var hasNewToken: Bool {
        if let oldToken = oldToken {
            return token == oldToken ? false : true
        }
        // No old token, it assumes that never before has a token been set
        return true
    }
}