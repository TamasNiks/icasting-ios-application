//
//  CastingObject.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// Expose an interface to get values from the casting object json
protocol CastingObjectValueProvider {
    var id: String? {get}
    var avatar: String? {get}
    var name: String? {get}
    var experience: String? {get}
    var profileLevel: String? {get}
    var jobRating: String? {get}
}

struct CastingObjectValues {
    
}


class CastingObject : CastingObjectValueProvider {
    
    let castingObject: JSON
    
    init(json: JSON) {
        self.castingObject = json
    }
    
    init() {
        self.castingObject = JSON("")
    }
    
    var id: String? {
        return self.castingObject["_id"].string
    }
    
    var avatar: String? {
        return self.castingObject["avatar"]["thumb"].string
    }
    
    var name: String? {
        return self.castingObject["name"]["display"].string ?? "-"
    }
    
    var experience: String? {
        let val: Int? = self.castingObject["xp"]["total"].int
        return (val == nil) ? "-" : "\(val!)"
    }
    
    var profileLevel: String? {
        return self.castingObject["name"]["display"].string ?? "-"
    }
    
    var jobRating: String? {
        let val: Int? = self.castingObject["jobRating"].int
        if let v = val {
            return "\(v)"
        }
        return "-"
    }

    
    
//    func summary() -> CastingObjectSummary {
//        
//    }
    
}

extension CastingObject : ModelRequest {
    
    internal func get(callBack: RequestClosure) {
        
        if let
            access_token = Auth.auth.access_token,
            user_id = Auth.auth.user_id
        {
            
            let url: String = APICastingObject.UserCastingObjects(user_id).value
            var params: [String : AnyObject] = ["access_token":access_token]
            
            request(.GET, url, parameters: params).responseJSON() { (request, response, json, error) in
                
                if (error != nil) {
                    NSLog("Error: \(error)")
                    println(request)
                    println(response)
                }
                
                if let json: AnyObject = json {
                    
                    println("CastingObjectRequest call success")
                    let json = JSON(json)
                    let errors: ICErrorInfo? = ICError(json: json).getErrors()
                    
                    if errors == nil {
                        
                        var castingObjects:[CastingObject] = json.arrayValue.map { CastingObject(json: $0) }
                        User.sharedInstance.castingObjects = castingObjects
                    }
                    
                    callBack(failure:errors)
                }
            }
        }
    }
}