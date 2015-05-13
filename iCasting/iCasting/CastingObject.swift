//
//  CastingObject.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

class CastingObject : ModelProtocol {
    
    
    
}

extension CastingObject {
    
    func get(callBack: RequestClosure) {
        
        if let access_token = Auth.auth.access_token {
            
            let url: String = APICastingObject.UserCastingObject(Auth.auth.user_id).value
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
                        var castingObjectIDs:[String] = [String]()
                        for (index: String, subJSON: JSON) in json {
                            let id: String = subJSON["id"].stringValue
                            castingObjectIDs.append(id)
                        }
                        
                        User.sharedInstance.castingObjectIDs = castingObjectIDs
                        User.sharedInstance.setCastingObject(0)
                    }
                    
                    callBack(failure:errors)
                }
            }
        }
    }
}