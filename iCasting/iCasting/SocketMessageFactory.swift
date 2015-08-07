//
//  SocketMessageFactory.swift
//  iCasting
//
//  Created by Tim van Steenoven on 31/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation



protocol SocketMessageFactoryProtocol {
    
    typealias DataType
    
    func createNormalMessage(data: DataType) -> Message
    func createOfferMessage(data: DataType) -> Message
    func createOfferContractMessage(data: DataType) -> Message
    func createRenegotiationRequestMessage(data: DataType) -> Message
    func createReportCompletedRequestMessage(data: DataType) -> Message
}




class SocketMessageFactory: SocketMessageFactoryProtocol  {
    
    typealias DataType = NSArray
    
    func createNormalMessage(data: DataType) -> Message {
        
        let body        : String = data[0] as! String
        let userID      : String = data[1] as! String
        let messageID   : String = data[2] as! String
        
        let role: MessageRole = MessageRole.getRole(userID) // Incomming, outgoing or system
        
        var message: Message
        if role == MessageRole.Incomming {
            message = Message(id: messageID, owner: userID, role: MessageRole.Incomming, type: TextType.Text)
            message.read = false
        } else {
            message = Message(id: messageID ?? String(), owner: userID, role: MessageRole.Outgoing, type: TextType.Text)
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
        
        let role: MessageRole = MessageRole.getRole(userID)
        
        let message: Message = Message(id: messageID, owner: userID, role: role, type: TextType.Offer)
        let offer: MessageOffer? = OfferSocketDataExtractor(offer: data).value
        message.offer = offer
        
        return message
    }
    
    
    func createOfferContractMessage(data: DataType) -> Message {
        
        let _message             = data[0] as? String
        let userID               = data[1] as! String
        let messageID            = data[2] as! String
        
        let role: MessageRole = MessageRole.getRole(userID)
        
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
        
        let role: MessageRole = MessageRole.getRole(userID)
        
        let message: Message = Message(id: messageID, owner: userID, role: role, type: TextType.RenegotationRequest)
        
        // When getting an renegotiation request from a sockets, it always starts with an accept client to true, because only a client can send an renegotation request
        let offer: MessageOffer? = MessageOffer(stateComponents: StateComponents(acceptClient: true, acceptTalent: nil, accepted: nil))
        message.offer = offer
        message.body = _message
        
        return message
    }
    
    func createReportCompletedRequestMessage(data: DataType) -> Message {
        
        let _message    = data[0] as? String
        let userID      = data[1] as! String
        let messageID   = data[2] as! String
        
        let role: MessageRole = MessageRole.getRole(userID)
        
        let message: Message = Message(id: messageID, owner: userID, role: role, type: TextType.ReportedComplete)
        
        // See commment createRenegotiationRequestMessage
        let offer: MessageOffer? = MessageOffer(stateComponents: StateComponents(acceptClient: nil, acceptTalent: nil, accepted: nil))
        message.offer = offer
        message.body = _message
        
        return message
    }
}