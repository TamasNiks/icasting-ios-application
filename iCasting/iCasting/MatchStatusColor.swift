//
//  MatchStatusColor.swift
//  iCasting
//
//  Created by Tim van Steenoven on 04/08/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

class MatchStatusColor {

    static func color(status: FilterStatusFields) -> UIColor? {
        
        switch status {
            
        case .Pending:
            return UIColor.lightGrayColor()
        case .TalentAccepted:
            return UIColor.orangeColor()
        case .Negotiations:
            return UIColor(red: 123/255, green: 205/255, blue: 105/255, alpha: 1)
        case .Closed:
            return UIColor.redColor()
        case .Completed:
            return UIColor(red: 123/255, green: 205/255, blue: 105/255, alpha: 1)
        default:
            return nil
        }
    }
    
}

