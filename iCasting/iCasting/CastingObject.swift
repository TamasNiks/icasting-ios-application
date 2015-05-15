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
    func avatar() -> String?
    func name() -> String?
}


class CastingObject : CastingObjectValueProvider {
    
    let castingObject: JSON
    
    init(json: JSON) {
        self.castingObject = json
    }
    
    init() {
        self.castingObject = JSON("")
    }
    
    func id() -> String? {
        return self.castingObject["_id"].string
    }
    
    func avatar() -> String? {
        return self.castingObject["avatar"]["thumb"].string
    }
    
    func name() -> String? {
        return self.castingObject["name"]["display"].string
    }
    
//    func summary() -> CastingObjectSummary {
//        
//    }
    
}

extension CastingObject : ModelRequest {
    
    internal func get(callBack: RequestClosure) {
        
        if let access_token = Auth.auth.access_token {
            
            let url: String = APICastingObject.UserCastingObjectsSummary(Auth.auth.user_id).value
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