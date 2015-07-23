//
//  ValueExtractor.swift
//  iCasting
//
//  Created by Tim van Steenoven on 12/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

enum MatchValueExtractor: Any {
    case Date(String?)
    case Time(String?)
    case Budget(Int?)
    case Boolean(Bool?)
    case Age(String?)
    
    // Further customize specific field data
    func modify() -> String? {
        
        var str: String?
        
        switch self {
        case .Date(let val):
            
            if let val = val { str = val.ICdateToString(ICDateFormat.Match) }
            
        case .Time(let val):
            
            if let val = val { str = val.ICTime() }
            
        case .Budget(let val):
            
            if let val = val { str = "\(val / 1000)" }
            
        case .Boolean(let val):
            
            if let val = val { str = NSLocalizedString(val.description, comment:"") }
            
        case .Age(let val):
            
            if let val = val {
                if val == "0" {
                    str = NSLocalizedString("matches.values.age.justborn", comment: "")
                } else {
                    let postfix = NSLocalizedString("matches.values.age.years", comment: "")
                    str = String(format: "%@ %@", arguments: [val, postfix])
                }
            }
        }
        return str
    }
}