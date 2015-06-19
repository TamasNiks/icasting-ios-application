//
//  ICError.swift
//  iCasting
//
//  Created by T. van Steenoven on 15-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


enum ICAPIErrorNames: String {
    case PassportAuthenticationError = "PassportAuthenticationError"
}

protocol ICErrorInfo : Printable {
    var type: ICErrorType { get }
    var localizedFailureReason: String { get }
}

enum ICErrorType : Int {
    case NetworkErrorInfo, APIErrorInfo, SocketErrorInfo
}


// These API error text keys correspondends to the name key of the API call, add new keys to the struct error and to the Localizable.strings file

private struct ICAPIErrorText {
    static let Names: [String] = ["AuthenticationError", "InsufficientCreditsError"]
    static let GenericError: String = "Error"
    static let NoErrorDescription: String = "NoErrorDescription"
}


struct ICSocketErrorInfo: ICErrorInfo {
    
    let errors: [String]
    let name: String
    
    
    var description: String {
        return "errors: \(errors)"
    }
    
    var type: ICErrorType {
        return ICErrorType.SocketErrorInfo
    }
    
    
    var localizedFailureReason: String {
        for value in ICAPIErrorText.Names {
            if value == name {
                return NSLocalizedString(value, comment: "The different API errors will be translated properly")
            }
        }
        return NSLocalizedString(errors[0], comment: "If an API error key does not exist, the original text will show up to give the user some information")
        //        if name == ICAPIErrorText.GenericError {
        //            return NSLocalizedString(errors[0], comment: "The different API errors will be translated properly")
        //        }
        
        //        return NSLocalizedString(ICAPIErrorText.NoErrorDescription, comment: "If an API error does not exist, this text will show up")
    }
    
}


struct ICNetworkErrorInfo : ICErrorInfo {
    
    let errors: [NSError]
    
    var description: String {
        return "errors: \(errors)"
    }
    
    var type: ICErrorType {
        return ICErrorType.NetworkErrorInfo
    }
    
    var localizedFailureReason: String {
        return errors[0].localizedDescription
    }
}


struct ICAPIErrorInfo : ICErrorInfo {
    
    let errors: [String]
    let name: String
    
    var description: String {
        return "errors: \(errors), name: \(name)"
    }
    
    var type: ICErrorType {
        return ICErrorType.APIErrorInfo
    }
    
    var localizedFailureReason: String {
        for value in ICAPIErrorText.Names {
            if value == name {
                return NSLocalizedString(value, comment: "The different API errors will be translated properly")
            }
        }
        return NSLocalizedString(errors[0], comment: "If an API error key does not exist, the original text will show up to give the user some information")
//        if name == ICAPIErrorText.GenericError {
//            return NSLocalizedString(errors[0], comment: "The different API errors will be translated properly")
//        }
        
//        return NSLocalizedString(ICAPIErrorText.NoErrorDescription, comment: "If an API error does not exist, this text will show up")
    }
    
}


// This class represents one access point to create error information depending on the type of an error, it returns the right structure containing error related information. It's up to the specific class to handle the errors
class ICError {
    
    var errorJson: JSON?
    var error: NSError?
    var socketError: String?
    
    init(json: JSON?) {
        self.errorJson = json
    }
    
    init(error: NSError?) {
        self.error = error
    }
    
    init(string: String?) {
        self.socketError = string
    }
    
    func getErrors() -> ICErrorInfo? {
        
        if let errorJson = self.errorJson {

            if let errors = errorJson["errors"].array {
                if errors.isEmpty == false {
                    var stringErrors: [String] = errors.map({ return $0.string! })
                    return ICAPIErrorInfo(errors: stringErrors, name: errorJson["name"].stringValue)
                }
            }
        }
        
        if let error: NSError = self.error {
            return ICNetworkErrorInfo(errors: [error])
        }
        
        
        if let error: String = self.socketError {
            return ICSocketErrorInfo(errors: [error], name: "Communication error")
        }
        
        return nil
    }
    
}