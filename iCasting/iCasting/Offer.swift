//
//  Offer.swift
//  iCasting
//
//  Created by Tim van Steenoven on 12/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


protocol OfferProtocol {
    var value: Offer? { get }
}





struct Offer {
    let name: String
    let values: [KeyVal]
    var accepted: Bool?
}





class OfferDataExtractor: OfferProtocol {

    // Override this for custom implementation
    var value: Offer? {
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
                val = extractor.modify(mutableDict[key])
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





class OfferHTTPDataExtractor: OfferDataExtractor {
 
    var offer: [String:JSON]?
    
    override var value: Offer? {
     
        if let o: [String:JSON] = offer {
            super.name              = o["path"]!.stringValue
            let accepted: Bool?     = o["accepted"]?.bool
            var dict: [String:JSON] = o["values"]!.dictionaryValue
            let values: [KeyVal] = super.getValues(dict)
            
            return Offer(name: super.name, values: values, accepted: accepted)
        }
        return nil
    }
    
    init(offer: [String:JSON]?) {
        self.offer = offer
    }
    
}





class OfferSocketDataExtractor: OfferDataExtractor {
    
    var offer: NSArray?
    
    override var value: Offer? {
        
        if let o = offer {
            var json: JSON = JSON(o[2])
            
            super.name                  = o[1] as! String
            var accepted: Bool?         //= (json["accepted"]?.dictionaryValue).keys
            var dict: [String:JSON]     = json.dictionaryValue
            
            let ignoreKeys = ["accepted", "mergedWithMatch"]
            super.removeValuesForKeys(fromDictionary: &dict, keys: ignoreKeys)
            var values: [KeyVal] = super.getValues(dict)
            
            return Offer(name: super.name, values: values, accepted: accepted)
        }
        return nil
    }
    
    init(offer: NSArray?) {
        self.offer = offer
    }
}





// Modify a specific value from the API with a string connected to a key/value pair

enum OfferValueExtractor: String {
    
    // The right enum key g
    case TypeDateTime = "type.dateTime"
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
            .TypeDateTime:
                
                let str = (v as! JSON).stringValue
                return getLocalizationForValue(str)
                
            case
            .DateStart,
            .DateEnd:
                
                let str = (v as! JSON).stringValue
                let components: [String] = str.componentsSeparatedByString("T")
                let invalidString: String = "Invalid date"
                return components.first?.ICdateToString(ICDateFormat.General) ?? (str.isEmpty ? invalidString : str)
                
            case
            .TimeStart,
            .TimeEnd:
                
                return (v as! JSON).stringValue
                
            case
            .HasBuyOff,
            .CompleteBuyOff,
            .HasTravelExpenses:
                
                let boolString = "\((v as! JSON).boolValue)"
                let result = getLocalizationForValue(boolString)
                return result
                
            case
            .Budget:
                
                var intVal = (v as! JSON).intValue
                intVal = intVal / 1000
                let result = "€ \(intVal)"
                return result
                
            case
            .BuyOffPeriod:
                
                let double = (v as! JSON).doubleValue
                let numOfMonths = Int(double * 12)
                
                var number: Int
                var postfix: String
                
                if numOfMonths > 11 { //years
                    number = Int(double)
                    postfix = number == 1 ? getLocalizationForValue("year") : getLocalizationForValue("years")
                    
                } else {
                    number = numOfMonths
                    postfix = number == 1 ? getLocalizationForValue("month") : getLocalizationForValue("months")
                }
                
                let period: String = "\(number) " + postfix
                let forever: String = getLocalizationForValue("forever")
                let result = numOfMonths == 0 ? forever : period
                return result
                
            case
            .BuyOffMedium:
                
                var result: String = String(", ").join((v as! JSON).arrayValue.map { $0.stringValue } )
                //result = result.isEmpty ? "-" : result
                return result
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
