//
//  Int+.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

extension Int {
    
    func toBool() -> Bool? {
        switch self {
        case 0:
            return false
        case 1:
            return true
        default:
            return nil
        }
    }
    
    var rgb: CGFloat {
        return CGFloat(self) / 255
    }
}