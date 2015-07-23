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
    func updateDevice(callBack: RequestClosure)
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


struct PushToken {

    private static let Old: String = "PushToken" // Token from the APNs or GCM
    private static let New: String = "NewPushToken" // Possible new token from the APNs or GCM

    static var token: String? {
        set(newValue) {
            println("PushToken: Sets the new token from a Cloud Messenger Service")
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: PushToken.New)
        }
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(PushToken.New)//objectForKey(PushToken.New) as? String
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
    
    // A more convenient way of knowing whether the new token already exist or not.
    static private var hasUpdatedToken: Bool {
        if let oldToken = oldToken {
            return PushToken.token == oldToken ? false : true
        }
        return true
    }
}


class Push: PushProtocol {
    
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
    
    func registerDevice(callBack: RequestClosure) {
        
        if PushToken.hasUpdatedToken || Push.deviceIDResponse.deviceID == nil {
            
            println("Push: Update in device token || deviceIDResponse == nil")
            requestForRegisterDevice(callBack)
        } else {
            println("Push: No update in device token and deviceIDResponse has been set")
        }
    }
    

    func deregisterDevice(callBack: RequestClosure) {

        if let deviceIDResponse = Push.deviceIDResponse.deviceID {
            
            let params = getParametersForDeregisterDevice()
            let req = Router.Push.DeviceID(deviceIDResponse, parameters: params)
            request(req).responseJSON() { (request, response, json, error) -> Void in
            
                if let error = ICError(error: error).getErrors() {
                    callBack(failure: error)
                    return
                }
                
                if let _json: AnyObject = json {
                    
                    let parsedJSON = JSON(_json)
                    if let errors = ICError(json: parsedJSON).getErrors() {
                        callBack(failure: nil)
                        return
                    }
                 
                    println(parsedJSON)
                    callBack(failure: nil)
                }
            }
        } else {
            println("DEBUG - Push: deviceIDResponse could not be set for deregistering device, probably because on simulator")
        }
    }
    
    
    func updateDevice(callBack: RequestClosure) {
        
        
    }

    
    // MARK: - Private methods
    
    // Do the actual request for registering a device at iCasting
    private func requestForRegisterDevice(callBack: RequestClosure) {
        
        if let parameters = getParametersForRegisterDevice() {
            
            let req = Router.Push.Device(parameters: parameters)
            request(req).responseJSON() { (request, response, json, error) -> Void in
                
                // Network or general errors?
                if let errors = ICError(error: error).getErrors() {
                    callBack(failure: errors)
                    return
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
                    
                    // No errors at all?
                    println(parsedJSON)
                    println("for token to save:")
                    println(PushToken.token)
                    
                    // Only if the device has been registered successfully, the push token can be saved locally
                    self.mapDeviceIDResponse(parsedJSON)
                    PushToken.save()
                    callBack(failure: nil)
                }
            }
            
        }
        else {
            println("DEBUG - Push: Parameters could not be set for registering device, probably because on simulator")
        }
    }
    
    
    private func requestForDeregisterDevice(callBack: RequestClosure) {
        
        
        
    }
    
    // TODO: In general, maybe put the parameters somewhere else
    private func getParametersForDeregisterDevice() -> [String : AnyObject] {
        
        var params = [String: AnyObject]()
        params["enabled"] = false
        return params
    }
    
    
    // The parameters are created for a register device HTTP request
    private func getParametersForRegisterDevice() -> [String : AnyObject]? {
    
        if let passport = Auth.passport {

            if let token: String = PushToken.token {
                
                var parameters: [String: AnyObject] = [String: AnyObject]()
                
                parameters[Passport.TOKEN_KEY]  = passport.access_token
                parameters["application"]   = "android"
                parameters["user"]          = passport.user_id
                
                var pushNotifications = [String: AnyObject]()
                pushNotifications["key"] = token
                pushNotifications["enabled"] = true
                
                parameters["pushNotification"] = pushNotifications
                
                return parameters
            }
        }
        
        return nil
    }

    
    private func mapDeviceIDResponse(json: JSON) {
        let id = json["_id"].stringValue
        Push.deviceIDResponse = DeviceIDResponse(_deviceID: id)
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