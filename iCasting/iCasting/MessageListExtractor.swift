//
//  MessageBuilder.swift
//  iCasting
//
//  Created by Tim van Steenoven on 28/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


// This class is responsible for getting the data from the json object and put it in a list wrapped around a Message object. This message object contains all the necessary information to view a message

protocol ListExtractor {
    typealias J
    func buildList(fromJSON json: J)
    func addMessage(message: Message)
}



class MessageListExtractor: NSObject, ListExtractor {
    
    typealias J = JSON
    
    dynamic var list:[Message] = [Message]()
    
    //dynamic var list2: [MessageObj] = [MessageObj]()
    
    func buildList(fromJSON json: JSON) {
        
        var m: [Message] = [Message]()
        
        for (index: String, subJson: JSON) in json {
            
            if let message: Message = construct(subJson) {
                m.append(message)
            }
        }
        
        self.list = m
    }
    
    // TODO: add subscript
    func addMessage(message: Message) {
        self.list.append(message)
    }
    
    func addOffer() {
        
        
    }
    
    func addContractOffer() {
        
        
    }

    private func construct(json: JSON) -> Message? {
        
        let type: String    =   json["type"].stringValue        // Offer, contract, system or text message
        
        // If a texttype does not exist, the message should not show, another option is to construct a system message in the else clausule
        
        if let textType: TextType = TextType(rawValue: type) {

            let id: String      =   json["_id"].stringValue     // Message id
            let owner: String   =   json["owner"].stringValue   // The id of the owner of the message
            let read: Bool      =   json["read"].boolValue      // Has the message been read
            var body: String    =   json["body"].stringValue    // If it is an text message, the body of the message
            let contract        =   MessageContract(contract: json["contract"].dictionaryValue).value   // Contract key value pairs
            let role: Role = getRole(owner)                     // Incomming, outgoing or system
            
            // Check if it is really an offer, before setting the internal offer, because sometimes the offer path exist even if it is a text based message
            var offer: MessageOffer.Offer?
            
            if textType == TextType.Offer {
                offer = MessageOffer(offer: json["offer"].dictionary).value
            }
            
            body = getLocalizationForTextType(textType, body: body)
            
            // First pass all the objects to
            let messageBuilder: MessageBuilder = MessageBuilder(
                id:     	id,
                owner:      owner,
                role:       role,
                type:       textType,
                body:       body,
                read:       read,
                contract:   contract,
                offer:      offer
            )
            
            let messageFactory: MessageFactory = MessageFactory()
            let message: Message = messageFactory.createMessage(messageBuilder: messageBuilder)
            
            return message
        }
        
        return nil
    }
    
    private func getLocalizationForTextType(textType: TextType, body: String) -> String {
    
        if textType == TextType.SystemText || textType == TextType.SystemContractUnaccepted {
            return NSLocalizedString(body, comment: "System text to translate")
        }
        return body
    }
    
    
    private func getRole(owner: String) -> Role {
        
        // TODO: Get the id from a casting object
        return (Auth.auth.user_id == owner) ? Role.Outgoing : Role.Incomming
    }

}



