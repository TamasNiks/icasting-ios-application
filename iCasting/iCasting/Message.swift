//
//  Message.swift
//  iCasting
//
//  Created by Tim van Steenoven on 09/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


struct KeyVal : SubscriptType {
    
    var key: String
    var val: String
    
    subscript(key: String) -> Any {
        return val
    }
}

// The role will be used to decide the where the message should be positioned
enum Role: Int {
    case Outgoing   // Message from the client user
    case Incomming  // Messages from the remote user
    case System     // Automatic messages by the API
}

// The TextType will be used to decide which type of message to show by the view
enum TextType: String {
    case SystemText                 = "system text"                         // Text by the API
    case SystemContractUnaccepted   = "system contract fields unaccepted"   // List of unaccepted negotiation points
    case Text                       = "text"                                // User text
    case Offer                      = "offer"                               // Overview of the offer points
}



// A class to hold message data and which is compatible to work with observer patterns like key-value and notifications, because an object is constructed from a class, it can be bridged to obj-c, in contrast to structs

class Message {

    let id: String
    let owner: String
    let role: Role
    let type: TextType
    
    var body: String?
    var read: Bool = false

    var contract: [MessageContract.NegotiationPoint]?   //The contract is optional, only the json list always gives contract values
    var offer: MessageOffer.Offer?                      // The offer is optional, because there is not always an offer key
    
    init(id: String, owner: String, role: Role, type: TextType) {

        self.id     = id
        self.owner  = owner
        self.role   = role
        self.type   = type
    }
}


// Different parts for a message are encapsulated

struct MessageContract {
    
    var contract: [String:JSON] = [String:JSON]()
    
    struct NegotiationPoint : Printable {
        let name: String
        let accepted: Bool
        var description: String { return "name: \(name), accepted: \(accepted)" }
    }
    
    
    var value: [NegotiationPoint] {
        
        var np = [NegotiationPoint]()
        let keys = Array(contract.keys)
        
        np = keys.map( { (key: String) -> NegotiationPoint in
            var isAccepted: Bool = self.contract[key]!["accepted"].boolValue
            return NegotiationPoint(name: key, accepted: isAccepted)
        })
        
        // TODO: Set on false
        np = np.filter({ (val: NegotiationPoint) -> Bool in
            return (val.accepted == true)
        })
        
        return np
    }
}


struct MessageOffer {
    
    var offer: [String:JSON]?
    
    struct Offer {
        let name: String
        let values: [KeyVal]
        let accepted: Bool?
    }
    
    
    var value: Offer? {
        
        if let o: [String:JSON] = offer {
            
            var name: String        = o["path"]!.stringValue
            var accepted: Bool?     = o["accepted"]?.bool
            var dict: [String:JSON] = o["values"]!.dictionaryValue
            var keys = Array(dict.keys)
            
            var values: [KeyVal] = keys.map( { (key: String) -> KeyVal in
                
                var val: String
                if let extractor = ValueExtractor(rawValue: key) {
                    val = extractor.modify(dict[key])
                } else {
                    val = "\(dict[key])"
                }
                
                // Return a String, String key-pair
                return KeyVal(key: key, val: val)
            })
            
            return Offer(name: name, values: values, accepted: accepted)
        }
        return nil
    }
    
    
    enum ValueExtractor: String {
        
        // Keys to extract the corresponding values
        case Type = "type"
        case DateStart = "dateStart"
        case TimeStart = "timeStart"
        case TimeEnd = "timeEnd"
        case HasBuyOff = "hasBuyOff"
        case CompleteBuyOff = "completeBuyOff"
        case HasTravelExpenses = "hasTravelExpenses"
        case Budget = "times1000"
        
        func modify(value: Any?) -> String {
            
            if let v = value {
                
                switch self {
                case
                .Type:
                    
                    var str = (v as! JSON).stringValue
                    return getLocalizationForValue(str)
                    
                case
                .DateStart:
                    
                    var str = (v as! JSON).stringValue
                    var formatted: String = str.ICdateToString(ICDateFormat.General) ?? str
                    return formatted
                    
                case
                .TimeStart,
                .TimeEnd:
                    
                    return (v as! JSON).stringValue
                    
                case
                .HasBuyOff,
                .CompleteBuyOff,
                .HasTravelExpenses:
                    
                    var boolString = "\((v as! JSON).boolValue)"
                    return getLocalizationForValue(boolString)
                    
                case
                .Budget:
                    
                    var int = (v as! JSON).intValue
                    var result = int / 1000
                    return "€ \(result)"
                }
            }
            return ""
        }
        
        private func getLocalizationForValue(value: String) -> String {
            
            var prefix = "negotiations.offer.value.%@"
            var formatted = String(format: prefix, value)
            return NSLocalizedString(formatted, comment: "")
        }
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
    
    let offer: MessageOffer.Offer
    
    init(id: String, owner: String, role: Role, type: TextType, offer: MessageOffer.Offer) {
        self.offer = offer
        super.init(id: id, owner: owner, role: role, type: type)
    }
}


/*****************************************************************/