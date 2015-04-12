//
//  Model.swift
//  iCasting
//
//  Created by T. van Steenoven on 08-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

private struct _User {
    static var sharedInstance : User = User()
}

class User {

    var id : String?
    var access_token : String {
        get {return "551d58a226042f74fb745533$HPjtsRhLGD24T8hIFlIMDUsWTbbt+zlfpDvWwOz41HI="}
    }
    
    init() {
        _User.sharedInstance = self
    }
    
    class func sharedInstance() -> User {
        return _User.sharedInstance
    }
    
}