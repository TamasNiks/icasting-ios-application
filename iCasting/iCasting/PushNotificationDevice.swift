//
//  PushNotificationDevice.swift
//  iCasting
//
//  Created by Tim van Steenoven on 29/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


protocol PushNotificationProtocol {
    func registerDevice(callBack: RequestClosure)
    func deregisterDevice(callBack: RequestClosure)
}


class PushNotificationDevice: PushNotificationProtocol {
    
    // After the registration of a device, the server will return a response with a device ID. The device ID string is given to the deviceIDresponse, and assigned to a computed property which will save the new value to persistent storage.
    static var deviceIDResponse: DeviceIDResponse {
        
        set(newValue) {
            newValue.save()
        }
        get {
            return DeviceIDResponse()
        }
    }
    
    // MARK: - Public interface
    
    static let sharedInstance = PushNotificationDevice()
    
    func registerDevice(callBack: RequestClosure) {
        
        
        if PushToken.hasUpdatedToken || PushNotificationDevice.deviceIDResponse.deviceID == nil {
            
            println("PushNotificationDevice: Update in device token: \(PushToken.hasUpdatedToken) || deviceIDResponse == nil: \(PushNotificationDevice.deviceIDResponse.deviceID)")
            
            requestForRegisterDevice(callBack)
            
        } else {
            println("PushNotificationDevice: No update in device token and deviceIDResponse has been set")
        }
    }
    

    func deregisterDevice(callBack: RequestClosure) {

        if let deviceIDResponse = PushNotificationDevice.deviceIDResponse.deviceID {
            
            if let parameters = getParametersForRegisterDevice(enabled: false) {
                
                let req = Router.Push.DeviceID(deviceIDResponse, parameters: parameters)
                request(req).responseJSON() { (request, response, json, error) -> Void in
                
                    var error = ICError(error: error).getErrors()

                    if let _json: AnyObject = json {
                        let parsedJSON = JSON(_json)
                        error = ICError(json: parsedJSON).getErrors()
                        println(parsedJSON)
                    }
                    
                    callBack(failure: error)
                }
            } else {
                println("DEBUG - PushNotificationDevice: Parameters could not be set for DEregistering device, but the user should be able to logout anyway")
                callBack(failure: nil)
            }
        } else {
            println("DEBUG - PushNotificationDevice: deviceIDResponse has not been set while wanting to DEregister device, probably because of simulator")
        }
    }
    
    

    // MARK: - Private methods
    
    // Do the actual request for registering a device at iCasting
    private func requestForRegisterDevice(callBack: RequestClosure) {
        
        if let parameters = getParametersForRegisterDevice(enabled: true) {
            
            let req = Router.Push.Device(parameters: parameters)
            request(req).responseJSON() { (request, response, json, error) -> Void in
                
                // Network or general errors?
                var error = ICError(error: error).getErrors()
                
                // No network errors, extract json
                if let _json: AnyObject = json {
                    
                    let parsedJSON = JSON(_json)
                    
                    // API Errors?
                    error = ICError(json: parsedJSON).getErrors()
                    
                    // No errors at all?
                    if error == nil {
                        
                        println(parsedJSON)
                        println("for token to save:")
                        println(PushToken.token)
                        // Only if the device has been registered successfully, the push token can be saved locally
                        self.mapDeviceIDResponse(parsedJSON)
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
    
    // TODO: In general, maybe put the parameters somewhere else
//    private func getParametersForDeregisterDevice() -> [String : AnyObject] {
//        
//        var params = [String: AnyObject]()
//        params["enabled"] = false
//        return params
//    }
    
    
    // The parameters are created for a register device HTTP request
    private func getParametersForRegisterDevice(#enabled: Bool) -> [String : AnyObject]? {
    
        if let passport = Auth.passport {

            if let token: String = PushToken.token {
                
                var parameters: [String: AnyObject] = [String: AnyObject]()
                parameters["application"]   = "android"
                parameters["user"]          = passport.user_id
                
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

    
    private func mapDeviceIDResponse(json: JSON) {
        let id = json["_id"].stringValue
        PushNotificationDevice.deviceIDResponse = DeviceIDResponse(_deviceID: id)
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


// The DeviceIDResponse will represent the Device ID given back by the server after device registration. The deviceID is needed when doing a patch request for when the  registration token has been updated. This way, the registration token, coupled to a user, will be synchronised with the server provider (iCasting). The trouble is, when the device ID gets lost, there is no possibility to update a registration token with the iCasting server.
struct DeviceIDResponse {
    
    private static let Key: String = "DeviceID" // ID key from the API
    
    private var _deviceID: String?
    
    func save() {
        NSUserDefaults.standardUserDefaults().setValue(_deviceID, forKey: DeviceIDResponse.Key)
    }
    
    var deviceID: String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(DeviceIDResponse.Key)
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
    }
    
    // Remove the old token
    static private func clear() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(PushToken.Old)
    }
    
    // A more convenient way of knowing whether the new token already exist or not. If a new token exist, it should be updated
    static private var hasUpdatedToken: Bool {
        if let oldToken = oldToken {
            return token == oldToken ? false : true
        }
        return true
    }
}