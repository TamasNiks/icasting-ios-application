//
//  ICError.swift
//  iCasting
//
//  Created by T. van Steenoven on 15-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


///Error domain
public let kICErrorDomain: String = "ICErrorDomain"

///Error codes
public let kICErrorAPI: Int = 100
public let kICErrorClientNotSupported: Int = 101
public let kICErrorEmailNotVerified: Int = 102


// These API error keys corresponds with the name key of the API call, add new keys to the struct error and to the Localizable.strings file
enum ICAPIErrorNames: String {
    case AuthenticationError = "AuthenticationError"
    case InsufficientCreditsError = "InsufficientCreditsError"
    case AlreadyRatedMatchError = "AlreadyRatedMatchError"
    case PassportAuthenticationError = "PassportAuthenticationError" //FB
}



protocol ICErrorInfo : Printable {
    var localizedDescription: String { get }
    var error: NSError { get }
}

private let localizedDescriptionComment = "The different API errors will be translated properly according to the name"
private let unknownDescription = "Unknown description"


struct ICSocketErrorInfo: ICErrorInfo {
    
    let errors: [String]
    let name: String
    
    
    var description: String {
        return "errors: \(errors)"
    }
    
    var localizedDescription: String {
        return error.localizedDescription ?? unknownDescription
    }
    
    var error: NSError {
        
        var errorDesc: String = ""
        if let APIName = ICAPIErrorNames(rawValue: name) {
            errorDesc = NSLocalizedString(APIName.rawValue, comment: localizedDescriptionComment)
        } else {
            errorDesc = NSLocalizedString(errors[0], comment: localizedDescriptionComment)
        }
        
        return NSError(domain: name, code: kICErrorAPI, userInfo: [NSLocalizedDescriptionKey : errorDesc])
    }
}


struct ICGeneralErrorInfo : ICErrorInfo {
    
    let errors: [NSError]
    
    var description: String {
        return "errors: \(errors)"
    }
    
    var localizedDescription: String {
        return errors[0].localizedDescription
    }
    
    var error: NSError {
        return errors[0]
    }
}


struct ICAPIErrorInfo : ICErrorInfo {
    
    let errors: [String]
    let name: String
    
    var description: String {
        return "errors: \(errors), name: \(name)"
    }
    
    var localizedDescription: String {
        return error.localizedDescription ?? unknownDescription
    }
    
    var error: NSError {
        var errorDesc = NSLocalizedString(errors[0], comment: localizedDescriptionComment)
        return NSError(domain: name, code: kICErrorAPI, userInfo: [NSLocalizedDescriptionKey : errorDesc])
    }
}


// This class represents one access point to create error information depending on the type of an error, it returns the right struct containing error related information. This struct acts as a wrapped for a NSError object. It's up to the specific class to handle the errors

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
        self.socketError = string == "<null>" ? nil : string
    }

    var errorInfo: ICErrorInfo? {
        
        if let errorJson = self.errorJson {

            if let errors = errorJson["errors"].array {
                if errors.isEmpty == false {
                    var stringErrors: [String] = errors.map({ return $0.stringValue })
                    return ICAPIErrorInfo(errors: stringErrors, name: errorJson["name"].stringValue)
                }
            }
        }
        
        if let error: NSError = self.error {
            return ICGeneralErrorInfo(errors: [error])
        }
        
        
        if let error: String = self.socketError {
            return ICSocketErrorInfo(errors: [error], name: "Communication error")
        }
        
        return nil
    }
}



// This extensions adds support for custom run time errors which are made on the fly when necessary. 
// Useful for restrictions that are not handled by the API

extension ICError {
    
     enum CustomErrorInfoType {
        
        case ClientNotSupportedError, EmailNotVerifiedError
        
        var errorInfo: ICErrorInfo {
            
            switch self {
                
            case .ClientNotSupportedError:
                
                let errorMessage = NSLocalizedString("alert.client.notsupported", comment: "")
                let error = NSError(domain: kICErrorDomain, code: kICErrorClientNotSupported, userInfo: [NSLocalizedDescriptionKey : errorMessage])
                return ICError(error: error).errorInfo!
                
            case .EmailNotVerifiedError:
                
                let errorMessage = NSLocalizedString("alert.user.emailnotverified", comment: "")
                let error = NSError(domain: kICErrorDomain, code: kICErrorEmailNotVerified, userInfo: [NSLocalizedDescriptionKey : errorMessage])
                return ICError(error: error).errorInfo!
                
            }
        }
    }
}