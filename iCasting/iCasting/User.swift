//
//  Model.swift
//  iCasting
//
//  Created by T. van Steenoven on 08-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

protocol UserCastingObject {
    
    func setCastingObject(index: Int) -> Bool
    func castingObjectAtIndex(index: Int) -> CastingObject
}

class User : Printable, ResponseObjectSerializable {

    struct Values : Printable {
        let name: String
        let first: String
        let avatar: String
        let credits: NSNumber
        let roles: [String]
        
        var description: String {
            return "name: \(name), first: \(first), credits: \(credits), roles\(roles)"
        }
    }
    
    static private var _sharedInstance: User = User()
    
    static var sharedInstance: User {
        return _sharedInstance
    }

    var values: Values?
    
    internal var credentials: Credentials = Credentials()
    internal var castingObjects: [CastingObject] = [CastingObject]()
    
    var castingObject: CastingObject = CastingObject()
    var castingObjectID: String {
        return castingObject.id ?? String()
    }

    // If the user is a family account, return true
    var isManager: Bool {
        if let values = values {
            for val: String in values.roles {
                if val == "manager" {
                    return true
                }
            }
        }
        return false
    }
    
    var isClient: Bool {
        if let values = values {
            return values.roles[0] == "client"
        }
        return false
    }
    
    
    var description: String {
        return "User: \(values?.description) \n castingObjects count: \(User.sharedInstance.castingObjects.count) \n castingObjectID: \(User.sharedInstance.castingObjectID) "
    }
    
    
    init() {}
    
    @objc required init?(response: NSHTTPURLResponse, representation: AnyObject) {
        
        self.setValues(JSON(representation))
        User._sharedInstance = self
    }
    
}


extension User : ValueProvider {
    
    private func setValues(json: JSON) {
        
        self.values = User.Values(
            name:       json["name"]["display"].string ?? "No name",
            first:      json["name"]["first"].string ?? "member",
            avatar:     json["avatar"]["thumb"].string ?? "",
            credits:    json["credits"]["total"].number ?? 0,
            roles:      json["roles"].arrayValue.map { return $0.stringValue }
        )
    }
}


extension User : UserCastingObject {
    
    func setCastingObject(index: Int) -> Bool {
        
        let isEmpty = castingObjects.isEmpty
        if isEmpty == false {
            println("UserCastingObject: Will set casting object at index")
            self.castingObject = self.castingObjects[index]
        }
        return (isEmpty) ? false : true
    }
    
    
    func castingObjectAtIndex(index: Int) -> CastingObject {
        
        return self.castingObjects[index]
    }
    
}


class UserRequest: RequestCommand {
    func execute(callBack:LoginClosure) {
        (User.sharedInstance as ModelRequest).get { (failure) -> () in
            callBack(failure: failure)
        }
    }
}


