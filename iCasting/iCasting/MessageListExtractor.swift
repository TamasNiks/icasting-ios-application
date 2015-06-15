//
//  MessageBuilder.swift
//  iCasting
//
//  Created by Tim van Steenoven on 28/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


// This class is responsible for getting the data from the json object and put it in a list wrapped around a Message object. This message object contains all the necessary information to view a message

protocol ListExtractorProtocol {
    typealias J
    typealias I
    func buildList(fromJSON json: J)
    func addItem(item: I)
}



class MessageListExtractor: NSObject, ListExtractorProtocol {
    
    typealias J = JSON
    typealias I = Message
    
    dynamic var list:[Message] = [Message]()
    
    var messageFactory: SocketMessageFactory2 = SocketMessageFactory2()
    
    func buildList(fromJSON json: JSON) {
        
        var m: [Message] = [Message]()
        
        for (index: String, subJson: JSON) in json {
            
            if let message: Message = constructMessage(fromJSON: subJson) {
                m.append(message)
            }
        }
        
        self.list = m
    }
    
    
    // TODO: add subscript
    func addItem(message: Message) {
        self.list.append(message)
    }
    
    
    // Construct a message from json data from a list of json objects
    
    private func constructMessage(fromJSON json: JSON) -> Message? {
        
        let type: String    =   json["type"].stringValue        // Offer, contract, system or text message
        
        // If a texttype does not exist, the message should not show, another option is to construct a system message in the else clausule
        
        if let textType: TextType = TextType(rawValue: type) {

            let id: String      =   json["_id"].stringValue     // Message id
            let owner: String   =   json["owner"].stringValue   // The id of the owner of the message
            let read: Bool      =   json["read"].boolValue      // Has the message been read
            var body: String    =   json["body"].stringValue    // If it is an text message, the body of the message
            let contract        =   MessageContract(contract: json["contract"].dictionaryValue).value   // Contract key value pairs
            let role: Role = Role.getRole(owner)                     // Incomming, outgoing or system
            
            // Check if it is really an offer, before setting the internal offer, because sometimes the offer path exist even if it is a text based message
            var offer: Offer?
            
            if textType == TextType.Offer {
                offer = OfferHTTPDataExtractor(offer: json["offer"].dictionary).value
            }
            
            body = getLocalizationForTextType(textType, body: body)
  
            // Message creation
            
            let message = Message(id: id, owner: owner, role: role, type: textType)
            message.body = body
            message.offer = offer
            message.contract = contract
            message.read = read
            
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
    
}





// Add behavior to extract and construct messages from socket data

extension MessageListExtractor {
    
    
    // Normal written message by the user
    func addNormalMessage(fromArray array: NSArray) {
        
        let message: Message = self.messageFactory.createNormalMessage(array)
        self.addItem(message)
    }
    
    // Offer message
    func addOffer(fromArray array: NSArray) {
    
        let message: Message = self.messageFactory.createOfferMessage(array)
        self.addItem(message)
    }
    
    
    func addContractOffer() {
        
        
    }
    
}







