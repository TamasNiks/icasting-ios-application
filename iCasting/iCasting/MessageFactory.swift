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


enum MessageFactoryType {
    case Socket
}

//class AbstractMessageFactory {
//
//    static func messageFactoryType(type: MessageFactoryType) -> MessageFactoryProtocol {
//
//        switch type {
//        case .Socket:
//            return SocketMessageFactory2()
//        }
//    }
//}



class SocketMessageFactory2: MessageFactoryProtocol  {
    
    typealias DataType = NSArray
    
    func createNormalMessage(data: DataType) -> Message {
     
        let body        : String = data[0] as! String
        let userID      : String = data[1] as! String
        let messageID   : String = data[1] as! String
        
        let role: Role = Role.getRole(userID) // Incomming, outgoing or system
        
        var message: Message
        if role == Role.Incomming {
            message = MessageMethodFactory.createIncommingNormalMessage(body: body, userID: userID, messageID: messageID)
        } else {
            message = MessageMethodFactory.createOutgoingNormalMessage(body: body, userID: userID, messageID: messageID)
        }

        return Message(id: "", owner: "", role: Role.Incomming, type: TextType.Text)
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


// The MessageFactory class makes creating Messags easier

class MessageMethodFactory {
    
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



//