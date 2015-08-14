//
//  PushToken.swift
//  iCasting
//
//  Created by Tim van Steenoven on 14/08/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// When the app starts, it receives a device token (push token) from the messenger service. Normally the app should register a device after login, but because it might be possible to get a token after the login has been finished (and thus could not register), the app will never register anymore for the current session, only after the user logged out manually and logged in again (because when the user doesn't logout, it steps over the login sequence), it is possible to register a device, because the push token has been set already into storage from the previous session. The PushTokenHandshaker wil solve this problem, because it only registers a device when a push token AND markToProceed has been set. You would set the markToProceed when login has been finised.

// In real life when the user terminates the app while logged in, the app memory will be reset. If the app starts again, cloud messenger service will deliver again a device token (new or the same). And after login suceed (if implemented, markToProceed has been called), it will update the device registration properly.

protocol PushTokenHandshakerObserver {
    func completedAddDeviceForRemoteNotificationWithFailure(failure: ICErrorInfo)
}

class PushTokenHandshaker {
    
    var delegate: PushTokenHandshakerObserver?
    
    static let sharedInstance = PushTokenHandshaker()
    
    var hasPushToken: Bool = false {
        didSet {
            checkToProceed()
        }
    }
    
    var hasMarkedToProceed: Bool = false {
        didSet {
            checkToProceed()
        }
    }
    
    func markToProceed() {
        hasMarkedToProceed = true
    }
    
    private func checkToProceed() {
        println("PushTokenHandshaker: checkToProceed with hasPushToken: \(hasPushToken), hasMarkedToProceed: \(hasMarkedToProceed)")
        if hasPushToken && hasMarkedToProceed {
            proceed()
        }
    }
    
    private func proceed() {
        println("PushTokenHandshaker: proceed")
        PushNotificationDevice.sharedInstance.addDeviceForRemoteNotifications() { possibleFailure in
            if let failure = possibleFailure {
                self.delegate?.completedAddDeviceForRemoteNotificationWithFailure(failure)
            }
        }
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
        
        // The app will register a device when it has been marked to complete
        PushTokenHandshaker.sharedInstance.hasPushToken = true
        }
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(PushToken.New)
        }
    }
    
    static private var oldToken: String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(PushToken.Old)
    }
    
    // Save the current token as an old token
    static internal func save() {
        NSUserDefaults.standardUserDefaults().setValue(PushToken.token, forKey: PushToken.Old)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // Remove the old token
    static private func clear() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(PushToken.Old)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // A more convenient way of knowing whether the new token already exist or not. If a new token exist, it should be updated
    static internal var hasNewToken: Bool {
        if let oldToken = oldToken {
            return token == oldToken ? false : true
        }
        // No old token, it assumes that never before has a token been set
        return true
    }
}