//
//  ModelRequest.swift
//  iCasting
//
//  Created by Tim van Steenoven on 17/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

protocol ModelRequest {
    func get(callBack: RequestClosure)
}




// COLLECTION
extension News : ModelRequest {
    
    func get(callBack: RequestClosure) {
        
        request(Router.News.NewsItems).responseCollection { (_, _, collection: [NewsItem]?, error) -> Void in
        
            var errors: ICErrorInfo? = ICError(error: error).getErrors()
            if let collection = collection {
                self.newsItems = collection
            }
            callBack(failure: errors)
            
        }
    }
    
    func image(id: String, size: ImageSize, callBack : ((success:AnyObject?, failure:NSError?)) -> () ) {
        
        let req = Router.Media.ImageWithSize(id, size.rawValue)
        request(req).response { (request, response, data, error) -> Void in
        
            callBack((success:data, failure:error))
        }
    }
}




// OBJECT
extension User : ModelRequest {
    
    func get(callBack:RequestClosure) {
        
        let req = Router.User.ReadUser(Auth.passport!.user_id)
        request(req).responseObject { (_, _, object: User?, error) -> Void in
            
            var errors: ICErrorInfo? = ICError(error: error).getErrors()
            callBack(failure: errors)
        }
    }
}




// COLLECTION
extension Notifications : ModelRequest {
    
    func get(callBack: RequestClosure) {
    
        request(Router.Notifications.Notifications).responseCollection { (request, response, collection: [NotificationItem]?, error) -> Void in
            
            var errors: ICErrorInfo? = ICError(error: error).getErrors()
            
            if let collection = collection {
                self.notifications = collection
            }
            
            callBack(failure: errors)
        }
        
    }
}




// COLLECTION
extension Match : ModelRequest {
    
    func get(callBack: RequestClosure) {
        
        println("CastingObjectID: "+User.sharedInstance.castingObjectID)
        
        // TODO: Change this to a particularly match request
        //let castingObjectID: String = User.sharedInstance.castingObjectID
        
        request(Router.Match.MatchCards).responseCollection { (_, _, collection: [MatchCard]?, error) -> Void in
            
            var errors: ICErrorInfo? = ICError(error: error).getErrors()
            
            if let collection = collection {
                self.initializeModel(collection)
            }
            
            callBack(failure: errors)
        }
    }
}




// COLLECTION
extension CastingObject : ModelRequest {
    
    internal func get(callBack: RequestClosure) {
        
        let req = Router.CastingObject.ReadUserCastingObjects(Auth.passport!.user_id)
        request(req).responseCollection { (_, _, collection: [CastingObject]?, error) -> Void in
            
            var error: ICErrorInfo? = ICError(error: error).getErrors()
            
            if let collection = collection {
                println("SUCCESS: CastingObject - Request call success with collection")
                User.sharedInstance.castingObjects = collection
                User.sharedInstance.setCastingObject(0)
            }
            
            callBack(failure:error)
        }
    }
}




extension Job : ModelRequest {
    
    func get(callBack: RequestClosure) {
        
        // Do request here
        let req = Router.Match.MatchPopulateJobOwner(self.matchID)
        request(req).responseJSON() { (request, response, json, error) -> Void in
            
            var errors: ICErrorInfo? = ICError(error: error).getErrors()
            
            if let json: AnyObject = json {
                
                let json = JSON(json)
                errors = ICError(json: json).getErrors()
                
                if errors == nil {
                    self.populate(json)
                }
            }
            
            callBack(failure: errors)
        }
    }
}

