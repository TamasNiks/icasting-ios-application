//
//  MessageFactory2.swift
//  iCasting
//
//  Created by Tim van Steenoven on 12/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation



protocol MessageFactoryProtocol {
    
    typealias DataType
    
    func createNormalMessage(data: DataType) -> Message
    func createOfferMessage(data: DataType) -> Message
    func createContractMessage(data: DataType) -> Message
    
}



class SocketMessageFactory: MessageFactoryProtocol  {
    
    typealias DataType = NSArray
    
    func createNormalMessage(data: DataType) -> Message {
     
        let body        : String = data[0] as! String
        let userID      : String = data[1] as! String
        let messageID   : String = data[2] as! String
        
        let role: Role = Role.getRole(userID) // Incomming, outgoing or system
        
        var message: Message
        if role == Role.Incomming {
            message = AbstractMessageMethodFactory.createIncommingNormalMessage(body: body, userID: userID, messageID: messageID)
        } else {
            message = AbstractMessageMethodFactory.createOutgoingNormalMessage(body: body, userID: userID, messageID: messageID)
        }

        return message//Message(id: "", owner: "", role: Role.Incomming, type: TextType.Text)
    }
    
    
    func createOfferMessage(data: DataType) -> Message {
        
        let userID    = data[3] as! String
        let messageID = data[4] as! String
        
        let message: Message = Message(id: messageID, owner: userID, role: Role.Incomming, type: TextType.Offer)
        let offer: Offer? = OfferSocketDataExtractor(offer: data).value
        message.offer = offer
        
        return message
    }
    
    func createContractMessage(data: DataType) -> Message {
        
        return Message(id: "", owner: "", role: Role.Incomming, type: TextType.Text)
    }
    
}


//class HTTPMessageFactory: MessageFactoryProtocol {
//    
//    typealias DataType = JSON
//    
//    static func createNormalMessage(data: DataType) -> Message {
//        
//    }
//    
//    static func createOfferMessage(data: DataType) -> Message {
//        
//    }
//    
//    static func createContractMessage(data: DataType) -> Message {
//        
//    }
//    
//}



// If the messages gets complexer, the message factory needs be improved

class AbstractMessageFactory {
    
    static func createMessage(fromJSON json: JSON) -> Message? {
        
        let type: String = json["type"].stringValue
        
        if let textType = TextType(rawValue: type) {
            
            let id: String      =   json["_id"].stringValue     // Message id
            let owner: String   =   json["owner"].stringValue   // The id of the owner of the message
            let role: Role = Role.getRole(owner)                     // Incomming, outgoing or system
            
            let message = Message(id: id, owner: owner, role: role, type: textType)
            
            let visitor = MessageVisitor(json: json)
            message.accept(visitor)
            return message
        }
        return nil
    }
}



// The MessageFactory class makes creating Messags easier

class AbstractMessageMethodFactory {
    
    static func createIncommingNormalMessage(#body: String, userID: String, messageID: String) -> Message {
        
        let message: Message = Message(
            id: messageID,
            owner: userID,
            role: Role.Incomming,
            type: TextType.Text
        )
        
        message.body = body
        message.read = false
        message.contract = nil
        message.offer = nil
        
        return message
    }
    
    
    static func createOutgoingNormalMessage(#body: String, userID: String, messageID: String? = nil) -> Message {
        
        let message: Message = Message(
            id:     messageID ?? String(),
            owner:  userID,
            role:   Role.Outgoing,
            type:   TextType.Text
        )
        
        message.body = body
        message.read = true
        message.contract = nil
        message.offer = nil
        
        return message
    }
    
}


