//
//  NSMutableURLRequest+Extensions.swift
//  iCasting
//
//  Created by Tim van Steenoven on 20/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {
    
    func addAuthorizationHeaderField()  {
        
        if let passport = Auth.passport {
            self.setValue("Bearer \(passport.accessToken)", forHTTPHeaderField: "Authorization")
        }
    }
    
    func addEmptyAuthorizationHeaderField() {
        
        self.setValue("", forHTTPHeaderField: "Authorization")
    }
    
}