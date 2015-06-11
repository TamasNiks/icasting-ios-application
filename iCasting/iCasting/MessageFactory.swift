//
//  MessageFactory.swift
//  iCasting
//
//  Created by Tim van Steenoven on 09/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// Hold all necessary json data in a simple structure from where it can passed to more specific objects

struct MessageBuilder : Printable {
    
    let id: String
    let owner: String
    let role: Role
    let type: TextType
    
    let body: String
    let read: Bool
    let contract: [MessageContract.NegotiationPoint]?   //The contract is optional, only the json list always gives contract values
    let offer: MessageOffer.Offer?                      // The offer is optional, because there is not always an offer key
    
    var description: String {
        return "id: \(id) body: \(body) role: \(role) read: \(read) type: \(type) owner: \(owner)"
    }
}


// The MessageFactory class is responsible for creating messages from a message builder object. Now the creation of specific objects is seperated from client objects

class MessageFactory {
    
    
    func createMessage(#messageBuilder: MessageBuilder) -> Message {
        
        let message: Message = Message(
            id: messageBuilder.id,
            owner: messageBuilder.owner,
            role: messageBuilder.role,
            type: messageBuilder.type
        )
        
        message.body        = messageBuilder.body
        message.read        = messageBuilder.read
        message.contract    = messageBuilder.contract
        message.offer       = messageBuilder.offer

        return message
    }
    
    
    func createIncommingMessage(#body: String, userID: String, messageID: String) -> Message {

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
    
    
    func createOutgoingMessage(#body: String, userID: String) -> Message {
        
        let message: Message = Message(
            id:     "",
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



    