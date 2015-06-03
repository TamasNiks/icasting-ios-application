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

class User : Printable, ModelProtocol, ValueProvider {

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
    
    static let sharedInstance: User = User()

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
    
    func initializeModel(json: JSON) {
        println("USER JSON")
        println(json)
        User.sharedInstance.setValues(json)
    }
    
    var description: String {
        return "User: \(values?.description) \n castingObjects count: \(User.sharedInstance.castingObjects.count) \n castingObjectID: \(User.sharedInstance.castingObjectID) "
    }
}


extension User : ValueProvider {
    
    func getValues() -> User.Values? {
        return values
    }
    
    private func setValues(json: JSON) {
        
        User.sharedInstance.values = User.Values(
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

extension User : ModelRequest {
    
    internal func get(callBack:RequestClosure) {
        
        if let passport = Auth.passport {
        
            let url: String = APIUser.User(passport.user_id).value
            var params: [String : AnyObject] = ["access_token":passport.access_token]
            
            request(.GET, url, parameters: params).responseJSON() { (request, response, json, error) in
                
                var errors: ICErrorInfo? = ICError(error: error).getErrors() //(json: json).getErrors()
                if let json: AnyObject = json {
                    
                    println("UserRequest call success")
                    let json = JSON(json)
                    errors = ICError(json: json).getErrors()
                    
                    if errors == nil {
                        self.initializeModel(json)
                    }
                    
                }
                
                callBack(failure: errors)
            }
        }
        
    }
}


