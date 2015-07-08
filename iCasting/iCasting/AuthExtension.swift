//
//  AuthExtension.swift
//  iCasting
//
//  Created by Tim van Steenoven on 15/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


// Client or Talent in state machine

protocol AuthenticateProtocol {
    
    func isAuthorized(context: Auth) -> Bool
    
}


class AuthorizedState: AuthenticateProtocol {

    func isAuthorized(context: Auth) -> Bool {
        return true
    }
    
}

class UnauthorizedState: AuthenticateProtocol {
    
    func isAuthorized(context: Auth) -> Bool {
        return false
    }
    
}

