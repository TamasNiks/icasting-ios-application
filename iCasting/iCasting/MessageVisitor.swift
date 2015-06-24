//
//  MessageVisitor.swift
//  iCasting
//
//  Created by Tim van Steenoven on 18/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

protocol MessageAcceptVisitorProtocol {
    func accept(visitor: MessageVisitor)
}

// If there are more type of messages, add the messages to the protocol
protocol MessageVisitorProtocol {
    func visits(element: Message)
}


class AbstractMessageVisitor: MessageVisitorProtocol {
    
    func visits(element: Message) {}
    
    internal func getLocalizationForTextType(textType: TextType, body: String) -> String {
        
        if textType == TextType.SystemText || textType == TextType.SystemContractUnaccepted || textType == TextType.ContractOffer {
            return NSLocalizedString(body, comment: "System text to translate")
        }
        return body
    }
}


class MessageVisitor: AbstractMessageVisitor {
    
    let json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    override func visits(message: Message) {
        
        let type: String    =   json["type"].stringValue        // Offer, contract, system or text message
        
        // If a texttype does not exist, the message should not show, another option is to construct a system message in the else clausule
        
        if let textType: TextType = TextType(rawValue: type) {

            var offer: Offer?
            let read: Bool      =   json["read"].boolValue      // Has the message been read or not
            var body: String    =   json["body"].stringValue    // If it is an text message, the body of the message will exist
            let contract        =   MessageContract(contract: json["contract"].dictionaryValue).value   // Contract key value pairs if they exist
 

            if textType == TextType.Offer {
                
                offer = OfferHTTPDataExtractor(offer: json["offer"].dictionaryValue).value
            }

            if textType == TextType.ContractOffer {

                offer = OfferContractHTTPDataExtractor(offer: json["offer"].dictionaryValue).value
                body = "icasting.chat.system.text.contractoffer"
            }
            
            if textType == TextType.RenegotationRequest {
                
                offer = OfferContractHTTPDataExtractor(offer: json["offer"].dictionaryValue).value
                body = "icasting.chat.system.text.renegotiationrequest"
            }
            
            body = super.getLocalizationForTextType(textType, body: body)
            
            message.body = body
            message.offer = offer
            message.contract = contract
            message.read = read
        }
    }
    
}
