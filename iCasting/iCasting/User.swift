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


protocol ValueProvider {
    
}

struct UserGeneral : Printable {
    let name: String
    let avatar: String
    let credits: NSNumber
    let roles: [String]
    
    var description: String {
        return "name: \(name), credits: \(credits), roles\(roles)"
    }
}

class User : Printable {

    var description: String {
        return "User: \(general?.description) \n castingObjects count: \(User.sharedInstance.castingObjects.count) \n castingObjectID: \(User.sharedInstance.castingObjectID) "
    }
    
    static let sharedInstance: User = User()

    internal var credentials: Credentials = Credentials()
    internal var castingObjects: [CastingObject] = [CastingObject]()
    
    var castingObject: CastingObject = CastingObject()
    var castingObjectID: String {
        get { return castingObject.id ?? String() }
    }

    var general: UserGeneral?
    
}


extension User : ValueProvider {
    
    func getGeneral() -> UserGeneral? {
        return general
    }
    
    private func setGeneral(json: JSON) {
        
        User.sharedInstance.general = UserGeneral(
            name: json["name"]["display"].string ?? "No name",
            avatar: json["avatar"]["thumb"].string ?? "",
            credits: json["credits"]["total"].number ?? 0,
            roles: json["roles"].arrayValue.map { return $0.stringValue }
        )
    }
    
}


extension User : UserCastingObject {
    
    func setCastingObject(index: Int) -> Bool {
        
        let isEmpty = castingObjects.isEmpty
        if isEmpty == false {
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
        
        if let
            access_token = Auth.auth.access_token,
            user_id = Auth.auth.user_id
        {
        
            let url: String = APIUser.User(user_id).value
            var params: [String : AnyObject] = ["access_token":access_token]
            
            request(.GET, url, parameters: params).responseJSON() { (request, response, json, error) in
                
                if(error != nil) {
                    NSLog("Error: \(error)")
                    println(request)
                    println(response)
                }
                
                if let json: AnyObject = json {
                    
                    println("UserRequest call success")
                    let json = JSON(json)
                    let errors: ICErrorInfo? = ICError(json: json).getErrors()
                    
                    if errors == nil {
//                        println("USER JSON")
//                        println(json)
                        User.sharedInstance.setGeneral(json)
                    }
                    
                    callBack(failure: errors)
                }
            }
        }
        
    }
}


