//
//  Validator.swift
//  iCasting
//
//  Created by T. van Steenoven on 15-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

/* This enum type contains all the functionality to validate it's values */

enum ErrorValidator {
    
    case EmptyEmail, EmptyPassword, WrongEmail
    
    func fails(field: String) -> Bool {
        
        switch self {
        case .EmptyEmail:
            return isEmpty(field)
        case .EmptyPassword:
            return isEmpty(field)
        case .WrongEmail:
            return isInvalidEmail(field)
        }
    }
    
    func getDescription() -> String {
        switch self {
        case .EmptyEmail:
            return "The e-mail is empty"
        case .EmptyPassword:
            return "The password field is empty"
        case .WrongEmail:
            return "Fill in a good e-mail"
        }
    }
    
    private func isInvalidEmail(string: String) -> Bool {
        
        let pattern: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let regularExpression: NSRegularExpression? = NSRegularExpression(
            pattern: pattern,
            options: NSRegularExpressionOptions(0),
            error: nil)
        
        var num: Int = 0
        if let regEx = regularExpression {
            num = regEx.numberOfMatchesInString(string, options: NSMatchingOptions(0), range: NSMakeRange(0, count(string)))
        }
        return num > 0 ? false : true
    }
    
    private func isEmpty(string: String) -> Bool {
        
        return count(string) == 0 ? true : false
    }

}

class Validator {
    
    var credentials: Credentials
    var errors: [ErrorValidator] = [ErrorValidator]()
    
    init(credentials: Credentials) {
        self.credentials = credentials
    }
    
    func check() -> [ErrorValidator]? {
        
        if ErrorValidator.EmptyEmail.fails(self.credentials.email) == true {
            errors.append(.EmptyEmail)
        }
        
        if ErrorValidator.WrongEmail.fails(self.credentials.email) == true {
            errors.append(.WrongEmail)
        }
        
        if ErrorValidator.EmptyPassword.fails(self.credentials.password) == true {
            errors.append(.EmptyPassword)
        }
        
        if errors.count > 0 {
            return errors
        }
        
        return nil
    }
    
}
