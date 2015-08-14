//
//  Contract.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/08/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

let formatErrorString: String = "?"

class Contract {
    
    var raw: JSON
    var root: String
    
    init(raw: JSON, root: String) {
        self.raw = raw
        self.root = root
    }
    
    
    func getPath(type: ContractPoint) -> JSON {
        return raw[root][type.rawValue]
    }
    
    var auditionType: ContractType {
        
        let type = ContractPoint.AuditionType
        let path = getPath(type)
        let values = [[type.rawValue : path["type"].stringValue]]
        let negotiatable = path["accepted"].boolValue
        return ContractType(name: type, values: values, negotiatable: negotiatable)
    }
    
    var requests: ContractType {
        
        let type = ContractPoint.Requests
        let path = getPath(type)
        let formatted = path["desc"].string ?? localizeString("norequests").localized
        let values = [[type.rawValue : formatted]]
        let negotiatable = path["accepted"].boolValue
        return ContractType(name: type, values: values, negotiatable: negotiatable)
    }
    
    var location: ContractType {
        
        let type = ContractPoint.Location
        let path = getPath(type)
        let values = createLocation(path["address"].dictionaryValue)
        let negotiatable = path["accepted"].boolValue
        return ContractType(name: type, values: values, negotiatable: negotiatable)
    }
    
    var dateTime: ContractType {
        
        let type = ContractPoint.DateTime
        let path = getPath(type)
        let values = createDateTime(path.dictionaryValue)
        let negotiatable = path["accepted"].boolValue
        return ContractType(name: type, values: values, negotiatable: negotiatable)
    }
    
    var travelExpenses: ContractType {
        
        let type = ContractPoint.TravelExpenses
        let path = getPath(type)
        let formatted =  OfferValueExtractor.HasTravelExpenses.modify(path["hasTravelExpenses"]) ?? formatErrorString
        let values = [[type.rawValue : formatted]]
        let negotiatable = path["accepted"].boolValue
        return ContractType(name: type, values: values, negotiatable: negotiatable)
    }
    
    var buyOff: ContractType {
        
        let type = ContractPoint.BuyOff
        let path = getPath(type)
        let values = createBuyOff(path.dictionaryValue)
        let negotiatable = path["accepted"].boolValue
        return ContractType(name: type, values: values, negotiatable: negotiatable)
    }
    
    var budget: ContractType {
        
        let type = ContractPoint.Budget
        let path = getPath(type)
        let formatted = OfferValueExtractor.Budget.modify(path["times1000"]) ?? formatErrorString
        let values = [[type.rawValue : formatted]]
        let negotiatable = path["accepted"].boolValue
        return ContractType(name: type, values: values, negotiatable: negotiatable)
    }
    
    var paymentMethod: ContractType {
        
        let type = ContractPoint.PaymentMethod
        let path = getPath(type)
        let values = [[type.rawValue : path["type"].stringValue]]
        let negotiatable = path["accepted"].boolValue
        return ContractType(name: type, values: values, negotiatable: negotiatable)
    }

    private func createDateTime(source: [String:JSON]) -> StringDictionaryArray {
        
        let formattedSource = formatWithOfferValueExtractor(source)
        
        let result = [
            ["dateStart" :  formattedSource["dateStart"]?.string],
            ["dateEnd"   :  formattedSource["dateEnd"]?.string],
            ["timeStart" :  formattedSource["timeStart"]?.string],
            ["timeEnd"   :  formattedSource["timeEnd"]?.string],
            ["range"     :  formattedSource["range"]?.string]
        ]
        
        return filterDictionaryInArrayForNil(result)
    }
    
    
    private func createLocation(source: [String:JSON]) -> StringDictionaryArray {
        
        let formattedSource = formatWithOfferValueExtractor(source)
        
        let result = [
            ["street"        :   formattedSource["street"]?.string],
            ["streetNumber"  :   formattedSource["streetNumber"]?.string],
            ["zipCode"       :   formattedSource["zipCode"]?.string],
            ["city"          :   formattedSource["city"]?.string],
            ["country"       :   formattedSource["country"]?.string]
        ]
        
        return filterDictionaryInArrayForNil(result)
    }
    
    
    private func createBuyOff(source: [String:JSON]) -> StringDictionaryArray {
        
        let formattedSource = formatWithOfferValueExtractor(source)
        
        let result = [
            ["hasBuyOff"        :   formattedSource["hasBuyOff"]?.string],
            ["medium"           :   formattedSource["medium"]?.string],
            ["period"           :   formattedSource["period"]?.string],
            ["completeBuyOff"   :   formattedSource["completeBuyOff"]?.string]
        ]
        
        return filterDictionaryInArrayForNil(result)
    }
 
    // Helper methods
    
    private func localizeString(string: String) -> (localized: String, format: String) {
        
        let formatted = String(format: "negotiations.offer.value.%@", string)
        let result = NSLocalizedString(formatted, comment: "")
        return (localized: result, format: formatted)
    }
    
    // MARK: - Format value extractor
    
    private func formatWithOfferValueExtractor(source: [String:JSON]) -> [String:JSON] {
        
        var formattedSource = [String:JSON]()
        
        for (key, val) in source {
            if let extractor = OfferValueExtractor(rawValue: key) {
                
                if let modified = extractor.modify(val) {
                    formattedSource[key] = JSON(modified)
                }
                
            } else {
                
                if let localized = checkLocalization(val) {
                    formattedSource[key] = JSON(localized)
                }
                else {
                    formattedSource[key] = val
                }
            }
        }
        return formattedSource
    }
    
    
    // Describe
    private func checkLocalization(val: JSON) -> String? {
        
        if let string = val.string {
            let result = localizeString(string)
            return result.localized == result.format ? nil : result.localized
        }
        return nil
    }
    
    
}