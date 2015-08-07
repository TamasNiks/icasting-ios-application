//
//  HTTPMessageFactory.swift
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



class HTTPMessageFactory: HTTPMessageFactoryProtocol {
    
    typealias DataType = JSON
    
    func createMessage(data: DataType) -> Message? {
        
        println(data)
        
        func getLocalizationForTextType(textType: TextType, body: String) -> String {
            
            if textType == TextType.SystemText || textType == TextType.SystemContractUnaccepted || textType == TextType.ContractOffer {
                return NSLocalizedString(body, comment: "System text to translate")
            }
            return body
        }
        
        
        // Get the type of the message, this type is used to decide which kind of messages should be constructed: Offer, contract, system or text message
        let type: String = data["type"].stringValue
        let id: String      =   data["_id"].stringValue     // Message id
        let owner: String   =   data["owner"].stringValue   // The id of the owner of the message
        let role: MessageRole = MessageRole.getRole(owner)                // Incomming, outgoing or system
        
        // If a text type does not exist, the message should not show, another option is to construct a system message in the else clausule
        if let textType = TextType(rawValue: type) {
            
            let message = Message(id: id, owner: owner, role: role, type: textType)

            // The basic parameters has been set for the message, now extract the other parameters
            var offer: MessageOffer?
            let read: Bool      =   data["read"].boolValue      // Has the message been read or not
            var body: String    =   data["body"].stringValue    // If it is an text message, the body of the message will exist
            let contract        =   MessageTerms(contract: data["contract"].dictionaryValue).value   // Contract key value pairs if they exist
            
            
            if textType == TextType.Offer {
                
                offer = OfferHTTPDataExtractor(offer: data["offer"].dictionaryValue).value
            }
            
            if textType == TextType.ContractOffer {
                
                offer = OfferContractHTTPDataExtractor(offer: data["offer"].dictionaryValue).value
                //body = "icasting.chat.system.text.contractoffer"
            }
            
            if textType == TextType.RenegotationRequest {
                
                offer = OfferContractHTTPDataExtractor(offer: data["offer"].dictionaryValue).value
                //body = "icasting.chat.system.text.renegotiationrequest"
            }
            
            if textType == TextType.ReportedComplete {
                
                offer = OfferReportedCompleteHTTPDataExtractor(offer: data["offer"].dictionaryValue).value
                //body = "icasting.chat.system.text.reportedcomplete"
            }
            
            body = getLocalizationForTextType(textType, body)
            
            message.body = body
            message.offer = offer
            message.contract = contract
            message.read = read
            
            
            // Experiment
            /*
            let visitor = MessageVisitor(json: json)
            message.accept(visitor)
            */

            return message
        }
        
        let message = Message(id: id, owner: owner, role: role, type: TextType.SystemText)
        message.body = "An error occured while trying to get the message: \"\(type)\". Please contact me at tim.van.steenoven@icasting.com and we will fix this issue."
        message.read = true
        
        return message
    }

}