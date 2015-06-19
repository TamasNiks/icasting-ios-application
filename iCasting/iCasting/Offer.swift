//
//  Offer.swift
//  iCasting
//
//  Created by Tim van Steenoven on 12/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


struct Offer {
    let name: String
    let values: [KeyVal]
    var accepted: Bool?
}


protocol OfferProtocol {
    var value: Offer? { get }
}


class OfferDataExtractor {

    private func getValues(dict: [String:JSON]) -> [KeyVal] {

        var keys = Array(dict.keys)
        
        var values: [KeyVal] = keys.map( { (key: String) -> KeyVal in
            
            var val: Any
            if let extractor = ValueExtractor(rawValue: key) {
                val = extractor.modify(dict[key])
            } else {
                if let subdictionary = dict[key]!.dictionary {
                    val = self.getValues(subdictionary)
                } else {
                    val = self.getUnwrappedStringValue(dict[key]!)
                }
            }
            
            // Return a String, Any key-pair
            return KeyVal(key: key, val: val)
        })
        
        return values
    }
    
    private func getUnwrappedStringValue(value: JSON) -> String {
        var val: String
        if let stringValue = value.string {
            val = stringValue
        } else {
            val = "\(value)"
        }
        return val
    }
    
}


class OfferHTTPDataExtractor: OfferDataExtractor, OfferProtocol {
 
    var offer: [String:JSON]?
    
    var value: Offer? {
     
        if let o: [String:JSON] = offer {
            var name: String        = o["path"]!.stringValue
            var accepted: Bool?     = o["accepted"]?.bool
            var dict: [String:JSON] = o["values"]!.dictionaryValue
            var values: [KeyVal] = super.getValues(dict)
            
            return Offer(name: name, values: values, accepted: accepted)
        }
        return nil
    }
    
    init(offer: [String:JSON]?) {
        self.offer = offer
    }
    
}


class OfferSocketDataExtractor: OfferDataExtractor, OfferProtocol {
    
    var offer: NSArray?
    
    var value: Offer? {
        
        if let o = offer {
            var json: JSON = JSON(o[2])
            
            var name: String                = o[1] as! String
            var accepted: Bool?             //= (json["accepted"]?.dictionaryValue).keys
            var dict: [String:JSON]         = json["mergedWithMatch"].dictionaryValue
            var values: [KeyVal] = super.getValues(dict)
            
            return Offer(name: name, values: values, accepted: accepted)
        }
        return nil
    }
    
    init(offer: NSArray?) {
        self.offer = offer
    }

}

// Modify a specific value from the API with a string connected to a key/value pair

enum ValueExtractor: String {
    
    // Keys to extract the corresponding values
    case Type = "type"
    case DateStart = "dateStart"
    case DateEnd = "dateEnd"
    case TimeStart = "timeStart"
    case TimeEnd = "timeEnd"
    case HasBuyOff = "hasBuyOff"
    case CompleteBuyOff = "completeBuyOff"
    case HasTravelExpenses = "hasTravelExpenses"
    case Budget = "times1000"
    case BuyOffPeriod = "period"
    case BuyOffMedium = "medium"
    
    func modify(value: Any?) -> String {
        
        if let v = value {
            
            switch self {
            case
            .Type:
                
                let str = (v as! JSON).stringValue
                return getLocalizationForValue(str)
                
            case
            .DateStart,
            .DateEnd:
                
                let str = (v as! JSON).stringValue
                let components: [String] = str.componentsSeparatedByString("T")
                return components[0].ICdateToString(ICDateFormat.General) ?? str
                
            case
            .TimeStart,
            .TimeEnd:
                
                return (v as! JSON).stringValue
                
            case
            .HasBuyOff,
            .CompleteBuyOff,
            .HasTravelExpenses:
                
                let boolString = "\((v as! JSON).boolValue)"
                return getLocalizationForValue(boolString)
                
            case
            .Budget:
                
                let int = (v as! JSON).intValue
                let result = int / 1000
                return "€ \(result)"
            case
            .BuyOffPeriod:
                
                let double = (v as! JSON).doubleValue
                let numOfMonths = Int(double * 12)
                let months: String = getLocalizationForValue("months")
                return "\(numOfMonths) " + months
            case
            .BuyOffMedium:
                
                return String(", ").join((v as! JSON).arrayValue.map { $0.stringValue } )
                
            }
        }
        return "Could not get value"
    }
    
    private func getLocalizationForValue(value: String) -> String {
        
        let prefix = "negotiations.offer.value.%@"
        let formatted = String(format: prefix, value)
        return NSLocalizedString(formatted, comment: "")
    }
}

//******************************************************************

//
//struct MessageOffer: OfferProtocol {
//    
//    var offer: [String:JSON]?
//    
//    var value: Offer? {
//        
//        if let o: [String:JSON] = offer {
//            
//            var name: String        = o["path"]!.stringValue
//            var accepted: Bool?     = o["accepted"]?.bool
//            var dict: [String:JSON] = o["values"]!.dictionaryValue
//            var keys = Array(dict.keys)
//            
//            var values: [KeyVal] = keys.map( { (key: String) -> KeyVal in
//                
//                var val: String
//                if let extractor = ValueExtractor(rawValue: key) {
//                    val = extractor.modify(dict[key])
//                } else {
//                    val = "\(dict[key])"
//                }
//                
//                // Return a String, String key-pair
//                return KeyVal(key: key, val: val)
//            })
//            
//            return Offer(name: name, values: values, accepted: accepted)
//        }
//        return nil
//    }
//    
//    
//}
//
//
//
//struct MessageOfferSocket: OfferProtocol {
//    
//    var offer: NSArray?
//    
//    var value: Offer? {
//        
//        if let o = offer {
//            
//            var json: JSON = JSON(o[2])
//            
//            var name: String                = o[1] as! String
//            var accepted: Bool?             //= (json["accepted"]?.dictionaryValue).keys
//            var dict: [String:JSON]         = json["mergedWithMatch"].dictionaryValue
//            var keys = Array(dict.keys)
//            
//            var values: [KeyVal] = keys.map( { (key: String) -> KeyVal in
//                
//                var val: String
//                if let extractor = ValueExtractor(rawValue: key) {
//                    val = extractor.modify(dict[key])
//                } else {
//                    val = "\(dict[key])"
//                }
//                
//                // Return a String, String key-pair
//                return KeyVal(key: key, val: val)
//            })
//            
//            return Offer(name: name, values: values, accepted: accepted)
//        }
//        return nil
//    }
//}





