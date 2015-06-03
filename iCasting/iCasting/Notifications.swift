//
//  Notifications.swift
//  iCasting
//
//  Created by Tim van Steenoven on 21/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// Encapsulate the extracting of the title and description of a notification

enum NotificationTypes: String {
    
    case
    AchievementComplete = "achievement-complete",
    MatchMatched = "match-matched",
    MatchClientAccepted = "match-client_accepted",
    ChatMessage = "chat-message",
    ChatOffer = "chat-offer"
    
    static let types: [NotificationTypes] = [AchievementComplete, MatchMatched, MatchClientAccepted, ChatMessage, ChatOffer]
    
    func getTitle() -> String {
        
        var prefix: String = "notification.title."
        return NSLocalizedString(prefix+rawValue, comment: "The title for a notification")
    }
    
    func getDescription(parameters: [String : JSON] ) -> String {
        
        var prefix: String = "notification.desc."
        var format: String = NSLocalizedString(prefix+rawValue, comment: "The description for a notification")
        
        switch self {
            
        case .AchievementComplete:
            var args: [CVarArgType] = [parameters["desc"]!.stringValue, String(stringInterpolationSegment: parameters["xpReward"]!.intValue)]
            return String(format: format, arguments: args)
            
        case .MatchMatched:
            var args: [CVarArgType] = [parameters["jobTitle"]!.stringValue]
            return String(format: format, arguments: args)
            
        case .MatchClientAccepted:
            var args: [CVarArgType] = [parameters["jobTitle"]!.stringValue]
            return String(format: format, arguments: args)
            
        case .ChatMessage:
            var args: [CVarArgType] = [parameters["jobTitle"]!.stringValue]
            return String(format: format, arguments: args)
            
        case .ChatOffer:
            return "Description of chat offer."//String(format: format, arguments: args)
        }
    }
    
    static func getType(type: String) -> NotificationTypes? {
        
        for obj: NotificationTypes in NotificationTypes.types {
            if obj.rawValue == type {
                return obj
            }
        }
        return nil
    }

    
}


//struct Notification : Printable {
//    
//    let id: String
//    let user: String
//    let type: String
//    let parameters: [String:JSON]
//    let pushState: [String:JSON]
//    let read: Bool
//    let created: String
//    
//    var description: String {
//        return "id: \(id), user: \(user), type: \(type), parameters: \(parameters), pushState: \(pushState), read: \(read), created: \(created)"
//    }
//}


class Notifications : ModelProtocol {
    
    struct NotificationBody : Printable {
        
        let title: String
        let desc: String
        let date: String
        
        var description: String {
            return "title: \(title), desc: \(desc), date: \(date)"
        }
        
    }
    
    //var notifications: [Notification] = [Notification]()
    var notifications: [NotificationBody] = [NotificationBody]()
    
    func initializeModel(json: JSON) {
     
        setBody(json)
    }
    
    private func setBody(json: JSON) {
        
        if let jsonArray: [JSON] = json.array {
            
            notifications = jsonArray.map( { (transform: JSON) -> NotificationBody in
                
                let type: String = transform["type"].stringValue
                let notificationType = NotificationTypes.getType(type)!
                
                let parameters = transform["parameters"].dictionaryValue
                let title = notificationType.getTitle()
                let desc = notificationType.getDescription(parameters)
                let created = transform["created"].stringValue.ICdateToString(ICDateFormat.News) ?? "no date"
                
                return NotificationBody(title: title, desc: desc, date: created)
            })
            
        }
        
    }
    
    subscript(index: Int) -> NotificationBody {
        return notifications[index]
    }
    
    //    func setNotifications(json: JSON) {
    //        if let jsonArray: [JSON] = json.array {
    //
    //            notifications = jsonArray.map( { (transform: JSON) -> Notification in
    //
    //                return Notification(
    //                    id: transform["id"].stringValue,
    //                    user: transform["user"].stringValue,
    //                    type: transform["type"].stringValue,
    //                    parameters: transform["parameters"].dictionaryValue,
    //                    pushState: transform["pushState"].dictionaryValue,
    //                    read: transform["read"].boolValue,
    //                    created: transform["created"].stringValue.ICdateToString(ICDateFormat.News) ?? "no date")
    //            })
    //        }
    //    }

}


extension Notifications : ModelRequest {
    
    func get(callBack: RequestClosure) {
        
        let url = APINotifications.Notifications.value
        let params = [Authentication.TOKEN_KEY : Auth.auth.access_token!]
        request(.GET, url, parameters: params, encoding: ParameterEncoding.URL).responseJSON { (request, response, json, error) -> Void in
            
            var errors: ICErrorInfo?
            if let error = error {
                errors = ICError(error: error).getErrors()
            }
            
            if let json: AnyObject = json {
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