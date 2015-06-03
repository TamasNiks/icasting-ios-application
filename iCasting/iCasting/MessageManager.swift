//
//  Message.swift
//  iCasting
//
//  Created by Tim van Steenoven on 28/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


struct KeyVal : SubscriptType {
    var key: String
    var val: Any
    
    subscript(key: String) -> Any {
        return val
    }
}


enum Role: Int {
    case User, Person, System
}


enum TextType: String {
    case
    SystemText = "system text",
    SystemContractUnaccepted = "system contract fields unaccepted",
    Text = "text",
    Offer = "offer"
    
    private static let type = [
        "system text"                       : TextType.SystemText,
        "system contract fields unaccepted" : TextType.SystemContractUnaccepted,
        "text"                              : TextType.Text,
        "offer"                             : TextType.Offer
    ]
    
    static func getType(val :String) -> TextType {
        return TextType.type[val] ?? TextType.Text
    }
    
}


struct Message : Printable {

    let id: String
    let body: String
    let role: Role
    let read: Bool
    let type: TextType
    let owner: String
    
    var contract: [String:JSON] = [String:JSON]()
    let offer: [String:JSON]?
    
    var description: String {
        return "id: \(id) body: \(body) role: \(role) read: \(read) type: \(type) owner: \(owner)"
    }
    
    struct NegotiationPoint : Printable {
        let name: String
        let accepted: Bool
        var description: String { return "name: \(name), accepted: \(accepted)" }
    }
    
    struct Offer {
        let name: String
        let values: [KeyVal]
        let accepted: Bool?
    }
    
    func getContractValues() -> [NegotiationPoint] {
        
        var np = [NegotiationPoint]()
        let keys = Array(contract.keys)

        np = keys.map( { (key: String) -> NegotiationPoint in
            var isAccepted: Bool = self.contract[key]!["accepted"].boolValue
            return NegotiationPoint(name: key, accepted: isAccepted)
        })
        
        np = np.filter({ (val: NegotiationPoint) -> Bool in
            return (val.accepted == true)
        })
        
        //println(np)
        
        return np
    }
    
    func getOffer() -> Offer? {
        
        if let o: [String:JSON] = offer {
            
            var name: String        = o["path"]!.stringValue
            var accepted: Bool?     = o["accepted"]?.bool
            var dict: [String:JSON] = o["values"]!.dictionaryValue
            var keys = Array(dict.keys)
            
            var values: [KeyVal] = keys.map( { (key: String) -> KeyVal in
                var d = dict
                return KeyVal(key: key, val: d[key] )
            })
        
            return Offer(name: name, values: values, accepted: accepted)
        }
        return nil
        
    }
    
    
    
}

// This class manages all the messages

class MessageManager {
    
    var messages:[Message] = [Message]()
    
    func setMessages(json: JSON) {
        
        var m: [Message] = [Message]()
        
        for (index: String, subJson: JSON) in json {
            
            let id: String      =   subJson["_id"].stringValue
            let owner: String   =   subJson["owner"].stringValue
            let read: Bool      =   subJson["read"].boolValue
            let type: String    =   subJson["type"].stringValue
            var body: String    =   subJson["body"].stringValue
            let contract        =   subJson["contract"].dictionaryValue
            let offer           =   subJson["offer"].dictionary
            
            let role: Role = getRole(owner)
            let textType: TextType = TextType.getType(type)
            
            if textType == TextType.SystemText || textType == TextType.SystemContractUnaccepted {
                body = NSLocalizedString(body, comment: "System text to translate")
            }
            
            let message: Message = Message(
                id:     	id,
                body:       body,
                role:       role,
                read:       read,
                type:       textType,
                owner:      owner,
                contract:   contract,
                offer:      offer
            )
            
            m.append(message)
        }
        
        messages = m
    }
    
    private func getRole(owner: String) -> Role {
        
        // TODO: Get the id from a casting object
        return (Auth.auth.user_id == owner) ? Role.User : Role.Person
    }

}



