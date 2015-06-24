//
//  CellIdentifier.swift
//  iCasting
//
//  Created by Tim van Steenoven on 22/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


// Bind the TextType of the cells with the CellIdentifiers, so the right cells will get reused.

class CellIdentifier {

    enum Message: String {
        
        // Cell identifiers
        case
        MessageCell                     = "messageCell",
        UnacceptedCell                  = "unacceptedMessageCell",
        SystemMessageCell               = "generalSystemMessageCell",
        OfferMessageCell                = "offerMessageCell",
        ContractOfferMessageCell        = "contractOfferMessageCell",
        RenegotiationRequestMessageCell = "renegotiationRequestMessageCell"
        
        static func fromTextType(type: TextType) -> CellIdentifier.Message? {
            var ids = [
                TextType.Text                       :   CellIdentifier.Message.MessageCell,
                TextType.SystemText                 :   CellIdentifier.Message.SystemMessageCell,
                TextType.SystemContractUnaccepted   :   CellIdentifier.Message.UnacceptedCell,
                TextType.Offer                      :   CellIdentifier.Message.OfferMessageCell,
                TextType.ContractOffer              :   CellIdentifier.Message.ContractOfferMessageCell,
                TextType.RenegotationRequest        :   CellIdentifier.Message.RenegotiationRequestMessageCell
            ]
            return ids[type]
        }
        
//        static func textType() -> TextType {
//            
//            for (key, value) in ids {
//                
//            }
//            
//        }
    }
    
}

