//
//  MessageOffer.swift
//  iCasting
//
//  Created by Tim van Steenoven on 12/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


protocol OfferProtocol {
    var value: MessageOffer? { get }
}


struct StateComponents {
    let acceptClient: Bool?
    let acceptTalent: Bool?
    let accepted: Bool?
}


// The offer class defines a final object for both a normal offer, which only the client can send and the talent needs to accept/reject and a mutual agreement which is reflected by the contract state property

class MessageOffer {
    let name: String?
    let values: [KeyVal]?
    var acceptTalent: Bool?
    var contractState: ContractState?
    
    private var _stateComponents: StateComponents?
    
    var stateComponents: StateComponents? {
        
        set {
            if let val = newValue {
                self._stateComponents = newValue
                self.contractState = ContractState.getState(
                    clientAccepted: val.acceptClient,
                    talentAccepted: val.acceptTalent,
                    accepted:       val.accepted)
            }
        }
        get {
            return _stateComponents
        }
    }
    
    init(name: String?, values: [KeyVal]?, acceptTalent: Bool?) {
        self.name = name
        self.values = values
        self.acceptTalent = acceptTalent
    }
    
    init(stateComponents: StateComponents) {
        self.name = nil
        self.values = nil
        self.stateComponents = stateComponents
    }
}


// The OfferDataExtractor defines a base class for extracting values comming from a data source like the server

class OfferDataExtractor: OfferProtocol {

    let formatErrorString: String = "Not formatted correctly"
    
    // Override this for custom implementation
    var value: MessageOffer? {
        get { return nil }
    }

    var name: String = String()
    
    internal func getValues(dict: [String:JSON]) -> [KeyVal] {

        var mutableDict = self.concatenateTypeKey(dict)
        var keys = Array(mutableDict.keys)
        
        var values: [KeyVal] = keys.map( { (key: String) -> KeyVal in
            
            var val: Any
            
            // First check if the value can be modified by the OfferValueExtractor
            if let extractor = OfferValueExtractor(rawValue: key) {
                val = extractor.modify(mutableDict[key]) ?? self.formatErrorString
            }
            // If the value cannot be modified, check if it's another dictionary, else just unwrap the value to a string
            else {
                if let subdictionary = mutableDict[key]!.dictionary {
                    //val = !subdictionary.isEmpty ? self.getValues(subdictionary) : String()
                    val = self.getValues(subdictionary)
                } else {
                    val = self.getUnwrappedStringValue(mutableDict[key]!)
                }
            }
            
            return KeyVal(key: key, val: val)
        })
        
        // For an extra check, remove all empty values, normally this should not be needed
        values = self.filterForEmpty(values)
        
        return values
    }
    
    private func filterForEmpty(values: [KeyVal]) -> [KeyVal] {
        
        return values.filter({ (element: KeyVal) -> Bool in
            if element.val is String {
                return (element.val as! String).isEmpty ? false : true
            }
            return true
        })
    }
    
    // Sometimes, the server can return a null value as a string, replace this value for an empty string
//    private func replaceNullString(string: String) -> String {
//        
//        return string == "<null>" ? String() : string
//    }
    
    private func getUnwrappedStringValue(value: JSON) -> String {
        
        var val: String
        if let stringValue = value.string {
            val = stringValue
        } else {
            val = "\(value)"
        }
        return val
    }
    
    // To make the "type" key more specific, concatenate it with the name of the offer. So it can be localized properly: "type.offerName". Don't forget to add it to the Localized.strings file
    private func concatenateTypeKey(dict: [String:JSON]) -> [String:JSON] {
        
        var mutableDict = dict
        if let removedVal = mutableDict.removeValueForKey("type") {
            let postfix: String = name.isEmpty ? String() : ".\(name)"
            let newKey: String = "type" + postfix
            mutableDict[newKey] = removedVal
        }
        return mutableDict
    }
    
    // Dependent on the source of data. Key values are sometimes mixed with other not related pieces of data. To properly extract the related key values from an offer, call this function.
    private func removeValuesForKeys(inout fromDictionary dictionary: [String:JSON], keys:[String]) -> [String:JSON] {
        
        var removed: [String:JSON] = [String:JSON]()
        for key in keys {
            removed[key] = dictionary.removeValueForKey(key)
        }
        return removed
    }

}



// Specialized classes for getting offer values from an HTTP call. It will try to create an offer object constructed with offer points

// OFFER

class OfferHTTPDataExtractor: OfferDataExtractor {
 
    var offer: [String:JSON]?
    
    init(offer: [String:JSON]?) {
        self.offer = offer
    }
    
    override var value: MessageOffer? {
     
        if let o: [String:JSON] = offer {
            super.name              = o["path"]?.stringValue ?? String()
            let accepted: Bool?     = o["accepted"]?.bool
            var dict: [String:JSON] = o["values"]?.dictionaryValue ?? [String:JSON]()
            let values: [KeyVal] = super.getValues(dict)
            
            return MessageOffer(name: super.name, values: values, acceptTalent: accepted)
        }
        return nil
    }
}

// Specialized class, it will try to get a mutual agreement (offer contract)

// OFFER CONTRACT

class OfferContractHTTPDataExtractor: OfferHTTPDataExtractor {
    
    override var value: MessageOffer? {
        
        if let o: [String:JSON] = offer {
            
            let acceptClient: Bool? = o["acceptClient"]?.bool
            let acceptTalent: Bool? = o["acceptTalent"]?.bool
            let accepted: Bool?     = o["accepted"]?.bool
            
            return MessageOffer(stateComponents: StateComponents(acceptClient: acceptClient, acceptTalent: acceptTalent, accepted: accepted))
        }
        return nil
    }
}

// Specialized class

// REPORTED COMPLETE

class OfferReportedCompleteHTTPDataExtractor: OfferHTTPDataExtractor {
    
    override var value: MessageOffer? {
        
        if let o: [String:JSON] = offer {
            
            let acceptClient: Bool? = o["acceptClient"]?.bool
            let acceptTalent: Bool? = o["acceptTalent"]?.bool
            let accepted: Bool?     = o["accepted"]?.bool
            return MessageOffer(stateComponents: StateComponents(acceptClient: acceptClient, acceptTalent: acceptTalent, accepted: accepted))
        }
        return nil
    }
}




// Specialized classes for getting values from a socket call

class OfferSocketDataExtractor: OfferDataExtractor {
    
    var offer: NSArray?
    
    override var value: MessageOffer? {
        
        if let o = offer {
            var json: JSON = JSON(o[2])
            
            super.name                  = o[1] as! String
            var accepted: Bool?         //= (json["accepted"]?.dictionaryValue).keys
            var dict: [String:JSON]     = json.dictionaryValue
            
            let ignoreKeys = ["accepted", "mergedWithMatch"]
            super.removeValuesForKeys(fromDictionary: &dict, keys: ignoreKeys)
            var values: [KeyVal] = super.getValues(dict)
            
            return MessageOffer(name: super.name, values: values, acceptTalent: accepted)
        }
        return nil
    }
    
    init(offer: NSArray?) {
        self.offer = offer
    }
}

//class OfferContractSocketDataExtractor: OfferSocketDataExtractor {
//    
//    override var value: Offer? {
//        
//        if let o = offer {
//            
//
//            //String message	Object userID	String message_id
//        }
//        
//        return nil
//    }
//}





