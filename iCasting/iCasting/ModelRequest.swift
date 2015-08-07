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

protocol ModelRequestID: ModelRequest {
    static func get(callBack: RequestCompletion, id: String)
}


typealias RequestCompletion = (success: AnyObject?, failure: ICErrorInfo?) -> ()



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
    
    func image(id: String, size: ImageSize, callBack: RequestCompletion) {
        
        let req = Router.Media.ImageWithSize(id, size.rawValue)
        request(req).response { (request, response, data, error) -> Void in
            
            let error: ICErrorInfo? = ICError(error: error).getErrors()
            callBack(success: data, failure: error)
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
extension MatchCollection : ModelRequest {
    
    func get(callBack: RequestClosure) {
        
        let castingObjectID: String = User.sharedInstance.castingObjectID
        let req = Router.Match.MatchesCastingObjectCards(castingObjectID)
        
        request(req).responseCollection { (_, _, collection: [MatchCard]?, error) -> Void in
            
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
    
    func get(callBack: RequestClosure) {
        
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




extension MatchCard : ModelRequestID {

    // OBJECT
    static func get(callBack: RequestCompletion, id: String) {
    
        let req = Router.Match.MatchPopulateJobOwner(id)
        request(req).responseObject { (request, response, object: MatchCard?, error) -> Void in

            let error: ICErrorInfo? = ICError(error: error).getErrors()
            callBack(success: object, failure: error)
        }
    }
    
    func get(callBack: RequestClosure) {}
    
    func rate(grade: String, callBack: RequestClosure) {
        
        let params: [String:AnyObject] = ["grade" : grade]
        let req = Router.Match.MatchRateClient(self.getID(FieldID.MatchCardID) ?? "0", parameters: params)
        request(req).responseJSON() { (request, response, json, error) in
            
            var error: ICErrorInfo? = ICError(error: error).getErrors()
            if let _json: AnyObject = json {
                error = ICError(json: JSON(_json)).getErrors()
            }
            
            callBack(failure: error)
        }
    }
}

extension Conversation : ModelRequest {
    
    func get(callBack: RequestClosure) {
        
        // This is a two step request, first get the conversation, and for instant sending and receiving messages, we need a conversation token
        let req = Router.Match.MatchConversation(self.matchID)
        request(req).responseJSON() { (request, response, json, error) -> Void in
            
            // Network or general errors?
            if let errors = ICError(error: error).getErrors() {
                callBack(failure: errors)
            }
            
            // No network errors, extract json
            if let _json: AnyObject = json {
                
                let messagesJSON = JSON(_json)
                
                // API Errors?
                if let errors = ICError(json: messagesJSON).getErrors() {
                    println(error)
                    callBack(failure: errors)
                    return
                }
                
                
                // There are no errors, perform the next request
                self.performRequestConversationToken(messagesJSON, callBack: callBack)
                
            }
        }
    }
    
    
    private func performRequestConversationToken(messagesJSON: JSON, callBack: RequestClosure) {
        
        // Request the conversation token
        self.requestConversationToken { (request, response, json, error) -> () in
            
            // Network or general errors?
            if let errors = ICError(error: error).getErrors() {
                callBack(failure: errors)
            }
            
            // No network errors, extract json
            if let _json: AnyObject = json {
                
                let tokenJSON = JSON(_json)
                
                // API Errors?
                if let errors = ICError(json: tokenJSON).getErrors() {
                    println(errors)
                    callBack(failure: errors)
                    return
                }
                
                // There are no errors, get everything to work
                self.setToken(tokenJSON)
                self.messageList.buildList(fromJSON: messagesJSON)
                
                // First, create a socket service, it wil set the delegate as well.
                self.createSocketCommunicationHandler()
                
                // Then let the controller know the first get request is ready, so it can prepare the view and observers.
                callBack(failure: nil)
                
                // After that, add the listeners, this method will call the delegate for the handlers
                self.socketCommunicator?.addListeners()
                
                // If everything is ready, start the socket
                self.socketCommunicator?.start()
                
            }
        }
    }
    
    
    private func requestConversationToken(callBack: JSONResponeType) {
        
        request(Router.Match.MatchConversationToken(self.matchID))
            .responseJSON() { (request, response, json, error) -> Void in
                callBack(request: request, response: response, json: json, error: error)
        }
    }
    
    
    private func setToken(json: JSON) {
        
        // TEST: if necessary, test all the values at once before create an instant of conversation token
        let values = [
            json["token"].stringValue,
            json["client"].stringValue,
            json["url"].stringValue]
        conversationToken = ConversationToken(token: values[0], client: values[1], url: values[2])
    }
}

