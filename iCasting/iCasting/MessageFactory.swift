//
//  MessageFactory2.swift
//  iCasting
//
//  Created by Tim van Steenoven on 12/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation



protocol HTTPMessageFactoryProtocol {
    
    typealias DataType
    func createMessage(data: DataType) -> Message?
}

protocol MessageFactoryProtocol {
    
    typealias DataType
    
    func createNormalMessage(data: DataType) -> Message
    func createOfferMessage(data: DataType) -> Message
    func createOfferContractMessage(data: DataType) -> Message
    func createRenegotiationRequestMessage(data: DataType) -> Message
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
            message = Message(id: messageID, owner: userID, role: Role.Incomming, type: TextType.Text)
            message.read = false
        } else {
            message = Message(id: messageID ?? String(), owner: userID, role: Role.Outgoing, type: TextType.Text)
            message.read = true
        }
        message.body = body
        message.contract = nil
        message.offer = nil
        
        return message
    }
    
    
    func createOfferMessage(data: DataType) -> Message {
        
        let userID    = data[3] as! String
        let messageID = data[4] as! String
        
        let role: Role = Role.getRole(userID)
        
        let message: Message = Message(id: messageID, owner: userID, role: role, type: TextType.Offer)
        let offer: MessageOffer? = OfferSocketDataExtractor(offer: data).value
        message.offer = offer
        
        return message
    }
    
    
    func createOfferContractMessage(data: DataType) -> Message {
     
        let _message             = data[0] as? String
        let userID               = data[1] as! String
        let messageID            = data[2] as! String

        let role: Role = Role.getRole(userID)
        
        let message: Message = Message(id: messageID, owner: userID, role: role, type: TextType.ContractOffer)

        // When getting an offer contract from a sockets, it always starts with NULL values
        let offer: MessageOffer? = MessageOffer(stateComponents: StateComponents(acceptClient: nil, acceptTalent: nil, accepted: nil))
        message.offer = offer
        message.body = _message
        
        return message
    }

    
    func createRenegotiationRequestMessage(data: DataType) -> Message {
        
        let _message    = data[0] as? String
        let userID      = data[1] as! String
        let messageID   = data[2] as! String
        
        let role: Role = Role.getRole(userID)
        
        let message: Message = Message(id: messageID, owner: userID, role: role, type: TextType.RenegotationRequest)
        
        // When getting an renegotiation request from a sockets, it always starts with an accept client to true, because only a client can send an renegotation request
        let offer: MessageOffer? = MessageOffer(stateComponents: StateComponents(acceptClient: true, acceptTalent: nil, accepted: nil))
        message.offer = offer
        message.body = _message
        
        return message
    }
}




class HTTPMessageFactory: HTTPMessageFactoryProtocol {
    
    typealias DataType = JSON
    
    func createMessage(data: DataType) -> Message? {
        
        func getLocalizationForTextType(textType: TextType, body: String) -> String {
            
            if textType == TextType.SystemText || textType == TextType.SystemContractUnaccepted || textType == TextType.ContractOffer {
                return NSLocalizedString(body, comment: "System text to translate")
            }
            return body
        }
        
        
        // Get the type of the message, this type is used to decide which kind of messages should be constructed.
        let type: String = data["type"].stringValue
        
        // If the text type does not exist, do something else
        if let textType = TextType(rawValue: type) {
            
            let id: String      =   data["_id"].stringValue     // Message id
            let owner: String   =   data["owner"].stringValue   // The id of the owner of the message
            let role: Role = Role.getRole(owner)                // Incomming, outgoing or system
            
            let message = Message(id: id, owner: owner, role: role, type: textType)
            
            let type: String    =   data["type"].stringValue        // Offer, contract, system or text message
            
            // If a texttype does not exist, the message should not show, another option is to construct a system message in the else clausule
            
            if let textType: TextType = TextType(rawValue: type) {
                
                var offer: MessageOffer?
                let read: Bool      =   data["read"].boolValue      // Has the message been read or not
                var body: String    =   data["body"].stringValue    // If it is an text message, the body of the message will exist
                let contract        =   MessageTerms(contract: data["contract"].dictionaryValue).value   // Contract key value pairs if they exist
                
                
                if textType == TextType.Offer {
                    
                    offer = OfferHTTPDataExtractor(offer: data["offer"].dictionaryValue).value
                }
                
                if textType == TextType.ContractOffer {
                    
                    offer = OfferContractHTTPDataExtractor(offer: data["offer"].dictionaryValue).value
                    body = "icasting.chat.system.text.contractoffer"
                }
                
                if textType == TextType.RenegotationRequest {
                    
                    offer = OfferContractHTTPDataExtractor(offer: data["offer"].dictionaryValue).value
                    body = "icasting.chat.system.text.renegotiationrequest"
                }
                
                body = getLocalizationForTextType(textType, body)
                
                message.body = body
                message.offer = offer
                message.contract = contract
                message.read = read
            }
            
            //let visitor = MessageVisitor(json: json)
            //message.accept(visitor)
            
            return message
        }
        return nil
    }

}