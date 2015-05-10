//
//  Model.swift
//  iCasting
//
//  Created by T. van Steenoven on 08-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

struct UserGeneral {
    

}

class User {

    static let sharedInstance: User = User()

    internal var credentials: Credentials = Credentials()
    
    var castingObjectIDs: [String] = [String]()
    var castingObjectID: String = String()

    var displayName: String?
    var avatar: String?
    var credits: NSNumber?
    var roles: [JSON]?
}

extension User {
    
    func setCastingObject(index:Int) {
        self.castingObjectID = self.castingObjectIDs[index]
    }
}


