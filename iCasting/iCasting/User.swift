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

extension User {
    
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


