//
//  Message.swift
//  iCasting
//
//  Created by Tim van Steenoven on 09/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


struct KeyVal {
    var key: String
    var val: Any
}


// The role will be used to decide where the message should be positioned inside the screen, the view is responsible for that. Another important issue is that when the client sends a message from the web while the negotiation screen is open, the message should be considered as outgoing.
enum Role: Int {
    case Outgoing   // Message from the client user
    case Incomming  // Messages from the remote user
    case System     // Automatic messages by the API
    
    static func getRole(owner: String) -> Role {
        // TODO: Get the id from a casting object
        return (Auth.auth.user_id == owner) ? Role.Outgoing : Role.Incomming
    }
}

// The TextType will be used to decide which type of message to show. The strings are corresponding to the value from the server response. The next step is to bind it with a specific cell in the view controller.
enum TextType: String {
    case SystemText                 = "system text"                         // Text by the API
    case SystemContractUnaccepted   = "system contract fields unaccepted"   // List of unaccepted negotiation points
    case Text                       = "text"                                // User text
    case Offer                      = "offer"                               // Overview of the offer points
    case ContractOffer              = "contract offer"
    case RenegotationRequest        = "renegotiation request"
}



// A class to hold message data and which is compatible to work with observer patterns like key-value and notifications, because an object is constructed from a class, it can be bridged to obj-c, in contrast to structs

class Message: MessageAcceptVisitorProtocol {

    let id: String
    let owner: String
    let role: Role
    let type: TextType
    
    var body: String?
    var read: Bool = false

    var contract: [MessageContract.NegotiationPoint]?   //The contract is optional, only the json list always gives contract values
    var offer: Offer?                                   // The offer is optional, because there is not always an offer key
    
    init(id: String, owner: String, role: Role, type: TextType) {

        self.id     = id
        self.owner  = owner
        self.role   = role
        self.type   = type
    }
    
    func accept(visitor: MessageVisitor) {
        visitor.visits(self)
    }
}





/*****************************************************************/

// Experiment

class BaseMessage {
    
    let id: String
    let owner: String
    let role: Role
    let type: TextType
    
    var read: Bool = false
    
    init(id: String, owner:String, role: Role, type: TextType) {
        self.id = id
        self.owner = owner
        self.role = role
        self.type = type
    }
}

class NormalMessage: BaseMessage {
    
    let message: String
    
    init(id: String, owner:String, role: Role, type: TextType, message: String) {
        
        self.message = message
        super.init(id: id, owner: owner, role: role, type: type)
    }
    
}

class NegotiationPointsMessage: BaseMessage {
    
    let contract: [MessageContract.NegotiationPoint]
    
    init(id: String, owner: String, role: Role, type: TextType, contract: [MessageContract.NegotiationPoint]) {
        self.contract = contract
        super.init(id: id, owner: owner, role: role, type: type)
    }
    
}


class OfferMessage: BaseMessage {
    
    let offer: Offer
    
    init(id: String, owner: String, role: Role, type: TextType, offer: Offer) {
        self.offer = offer
        super.init(id: id, owner: owner, role: role, type: type)
    }
}


class OfferContractMessage: BaseMessage {
    
    let message: String = "Do you want to accept the contract?"
    
    override init(id: String, owner: String, role: Role, type: TextType) {
        super.init(id: id, owner: owner, role: role, type: type)
    }
}

/*****************************************************************/