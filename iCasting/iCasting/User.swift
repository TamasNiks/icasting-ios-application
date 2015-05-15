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
    func castingObjectForIndex(index: Int) -> CastingObject
}

class User {

    static let sharedInstance: User = User()

    internal var credentials: Credentials = Credentials()
    internal var castingObjects: [CastingObject] = [CastingObject]()
    
    var castingObject: CastingObject = CastingObject()
    var castingObjectID: String {
        get { return castingObject.id() ?? String() }
    }

    var displayName: String?
    var avatar: String?
    var credits: NSNumber?
    var roles: [JSON]?
}

extension User : UserCastingObject {
    
    func setCastingObject(index: Int) -> Bool {
        
        let isEmpty = castingObjects.isEmpty
        if isEmpty == false {
            self.castingObject = self.castingObjects[index]
        }
        return (isEmpty) ? false : true
    }
    
    func castingObjectForIndex(index: Int) -> CastingObject {
        return self.castingObjects[index]
    }
    
}

extension User : ModelRequest {
    
    internal func get(callBack:RequestClosure) {
        
        if let access_token = Auth.auth.access_token {
        
            let url: String = APIUser.User(Auth.auth.user_id).value
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
                        User.sharedInstance.displayName = json["name"]["display"].string
                        User.sharedInstance.credits = json["credits"]["total"].number!
                        User.sharedInstance.avatar = json["avatar"]["thumb"].string
                        User.sharedInstance.roles = json["roles"].array
                    }
                    
                    callBack(failure: errors)
                }
            }
        }
        
    }
}


