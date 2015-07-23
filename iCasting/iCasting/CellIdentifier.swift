//
//  CellIdentifier.swift
//  iCasting
//
//  Created by Tim van Steenoven on 22/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


protocol CellIdentifierProtocol {
    var rawValue: String { get }
}


// Bind the TextType of the cells with the CellIdentifiers, so the right cells will get reused.

enum CellIdentifier {

    enum NegotiationOverview: String, CellIdentifierProtocol {
        case
        Default = "conversationCellidentifier"
    }
    
    enum Message: String, CellIdentifierProtocol {
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
    }
    
    enum JobOverview: String, CellIdentifierProtocol {
        case
        Header = "headerCellIdentifier",
        JobPoints = "jobPointsCellIdentifier",
        AdditionalRequests = "jobPointsAdditionalCellIdentifier"
    }
    
    enum Match: String, CellIdentifierProtocol {
        case
        Detail = "matchDetailCellIdentifier"
    }
    
    enum MatchDetail: String, CellIdentifierProtocol {
        case
        Header = "headerCell",
        Dilemma = "dilemmaCell",//"acceptCell",
        Summary = "summaryCell",
        Profile = "profileCell",
        Detail = "detailCell"
    }
    
    enum MatchProfile: String, CellIdentifierProtocol {
        case
        Default = "reuseIdentifierCell"
    }
    
    enum Settings: String, CellIdentifierProtocol {
        case
        LogOut = "logoutCellID",
        ChangeCastingObject = "changeCastingObjectCellID"
    }
}

