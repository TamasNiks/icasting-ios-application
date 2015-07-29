//
//  Job.swift
//  iCasting
//
//  Created by Tim van Steenoven on 26/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


func += <KeyType, ValueType> (inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

typealias StringDictionaryArray = [[String : String]]

struct ContractType {
    //let values: [ContractPoint:[String:String]]
    let name: ContractPoint
    let values: StringDictionaryArray
    let negotiatable: Bool
}

// The points below are the global topics under where everything falls. The strings are to help to localize the name of the topics
enum MainTopic: String {
    case
    General             = "general",
    Finance             = "finance",
    BuyOff              = "buyoff",
    TimeLocation        = "timeandlocation",
    AdditionalRequests  = "additionalrequests"
}

// The points below are the sub topics which can be negotiated
enum ContractPoint: String {
    case
    AuditionType    = "auditionType",
    Requests        = "requests",
    Location        = "location",
    DateTime        = "dateTime",
    TravelExpenses  = "travelExpenses",
    BuyOff          = "buyOff",
    Budget          = "budget",
    PaymentMethod   = "paymentMethod"
}

typealias JobContractArray = [[MainTopic:[ContractType]]]

class Job {
    
    let formatErrorString: String = "Not formatted correctly"
    
    var list: JobContractArray = JobContractArray()
    
    private var source: JSON = JSON("")
    let matchID: String
    private var root: [SubscriptType] = ["contract"]
    
    func getPath(type: ContractPoint) -> JSON {
        return source[root][type.rawValue]
    }
    
    var title: String {
        return source["job", "title"].string ?? "No title given"
    }
    
    var description: String {
        return source["job", "descLong"].string ?? "No description given"
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
    
    init(matchID: String) {
    
        // The match ID will be used for a API request
        self.matchID = matchID
    }
    
    func populate(source: JSON) {
        
        self.source = source
        self.buildList()
    }
    
    func resolveList() {
        
        
        
    }
    
    
    
    // MARK: Private methods
    
    private func buildList() {
        
        var resultList = JobContractArray()
        resultList.append([.Finance             :   [budget, travelExpenses]])
        resultList.append([.BuyOff              :   [buyOff]])
        resultList.append([.TimeLocation        :   [dateTime, location]])
        resultList.append([.AdditionalRequests  :   [requests]])
        
        self.list = resultList
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
    
    
    private func formatWithOfferValueExtractor(source: [String:JSON]) -> [String:JSON] {

        var formattedSource: [String:JSON] = [String:JSON]()
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
    
    
    private func checkLocalization(val: JSON) -> String? {
    
        if let string = val.string {
            
            let result = localizeString(string)
            return result.localized == result.format ? nil : result.localized
        }
        return nil
    }
    
    
    private func localizeString(string: String) -> (localized: String, format: String) {
        
        let prefix = "negotiations.offer.value.%@"
        let formatted = String(format: prefix, string)
        let result = NSLocalizedString(formatted, comment: "")
        return (localized: result, format: formatted)
    }
    
}