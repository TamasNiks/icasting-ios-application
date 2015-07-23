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
    MatchClientRejected = "match-client_rejected",
    ChatMessage = "chat-message",
    ChatOffer = "chat-offer"
    
    func getTitle() -> String {
        
        var prefix: String = "notification.title."
        return NSLocalizedString(prefix+rawValue, comment: "The title for a notification")
    }
    
    func getDescription(parameters: [String : JSON] ) -> String {
        
        var prefix: String = "notification.desc."
        var format: String = NSLocalizedString(prefix+rawValue, comment: "The description for a notification")
        
        switch self {
            
        case
        .AchievementComplete:
            var args: [CVarArgType] = [parameters["desc"]!.stringValue, String(stringInterpolationSegment: parameters["xpReward"]!.intValue)]
            return String(format: format, arguments: args)
            
        case
        .MatchMatched,
        .MatchClientAccepted,
        .MatchClientRejected,
        .ChatMessage,
        .ChatOffer:
            if let jobTitle = parameters["jobTitle"] {
                var args: [CVarArgType] = [jobTitle.stringValue]
                return String(format: format, arguments: args)
            } else {
                return "-"
            }
        }
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


final class NotificationItem : Printable, ResponseCollectionSerializable {
    
    let title: String
    let desc: String
    let date: String
    
    init(title: String, desc: String, date: String) {
        self.title = title
        self.desc = desc
        self.date = date
    }
    
    var description: String {
        return "title: \(title), desc: \(desc), date: \(date)"
    }
    
    @objc static func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [NotificationItem] {
        
        var list = [NotificationItem]()
        if let representation = representation as? [AnyObject] {
            
            list = representation.map { (transform: AnyObject) -> NotificationItem in
                
                let transform = JSON(transform)
                
                let type: String = transform["type"].stringValue
                
                if let notificationType = NotificationTypes(rawValue: type) {
                    
                    let parameters = transform["parameters"].dictionaryValue
                    let title = notificationType.getTitle()
                    let desc = notificationType.getDescription(parameters)
                    let created = transform["created"].stringValue.ICdateToString(ICDateFormat.News) ?? "no date"
                    return NotificationItem(title: title, desc: desc, date: created)
                }
                
                println("DEBUG: \(type)")
                return NotificationItem(title: "Unknown notification", desc: "Please contact me @ tim.van.steenoven@icasting.com", date: "-")
            }
            return list
        }
        
        return [NotificationItem]()
    }
}


class Notifications: SubscriptType {
    
    var notifications: [NotificationItem] = [NotificationItem]()
    
    subscript(index: Int) -> NotificationItem {
        return notifications[index]
    }
}


