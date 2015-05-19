//
//  MatchValues.swift
//  iCasting
//
//  Created by Tim van Steenoven on 15/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// Convenient shortcut to get all the detail values
typealias MatchHeaderType = [Fields:String?]
typealias MatchDetailType = [Fields: [ [String:String?] ] ] // Dictionary with Fields key and a an array of Dictionaries of type String key values
typealias MatchContractType = (header: MatchHeaderType, details: MatchDetailType)


typealias ArrayStringValue = [[String:String]]
typealias ArrayStringStringBool = [[String: [String:Bool]]]

// STATIC VALUE EXTRACTOR AND DYNAMIC VALUE EXTRACTOR
// Access to singular values as well as group values


func ==(lhs: MatchCard, rhs: MatchCard) -> Bool {
    return lhs.getID(FieldID.MatchCardID) == rhs.getID(FieldID.MatchCardID)
}


class MatchCard : NSObject, Equatable, Printable {
    
    private var matchCard: JSON = JSON("")
    private let contract: [SubscriptType] = FieldRoots.RootJobContract.getPath()
    private let profileRoot: [SubscriptType] = FieldRoots.RootJobProfile.getPath()
    private var titles: [String] = [String]()
    private var profile: [ArrayStringValue] = [ArrayStringValue]()
    
    var delegate: MatchCardDelegate?
    
    var raw: JSON {
        return matchCard
    }
    
    override var description: String {
        return profile.description
    }
    
    init(matchCard: JSON) {
        super.init()
        
        self.matchCard = matchCard
        
        let include = [profileHair, profileFirstLevel, profileLanguage, profileNear]
        self.profile = filterNil(include)
    }
    
    subscript(index: Int) -> ArrayStringValue {
        return profile[index]
    }

}




extension MatchCard {
    
    var profileFirstLevel: ArrayStringValue? {
        
        if let result = matchCard[profileRoot].dictionary {
            var dict: [String:String] = [String:String]()
            for (key: String, sub: JSON) in result {
                
                if let stringVal = sub.string {
                    dict[key] = sub.stringValue
                }
                if let arrayVal = sub.array {
                    dict[key] = String(", ").join(arrayVal.map { $0.stringValue })
                }
            }
            
            return Array(dict.keys).map { [$0:dict[$0]!] }
        }
        return nil
    }
    
    var profileNear: ArrayStringValue? {
        
        if let result = matchCard[profileRoot]["near"].dictionary {
            var dict: [String:String] = [String:String]()
            for (key: String, sub: JSON) in result {
                dict[key] = sub.stringValue
            }
            return Array(dict.keys).map { [$0:dict[$0]!] }
        }
        return nil
    }
    
    var profileLanguage: ArrayStringValue? {
        
        if let result = matchCard[profileRoot]["languages"].dictionary {
            var dict: [String:String] = [String:String]()
            for (key: String, sub: JSON) in result {
                
                dict[key] = sub["level"].stringValue
                
            }
            return Array(dict.keys).map { [$0:dict[$0]!] }
        }
        return nil
    }
    
    // Example: { hair { face { isGraying : false, isBold : false } } } will become: { head { face : "noGraying, noBold" } }
    var profileHair: ArrayStringValue? {
        
        // Get the dictionary called hair of exist
        if let result = matchCard[profileRoot]["hair"].dictionary {
            
            // Create a new dictionary to store strings at a string key
            var dict: [String:String] = [String:String]()
            
            // Loop through every dictionary value of hair, key will be "face", sub will be "{ isGraying : false, isBold : false }
            for (key: String, sub: JSON) in result {
                
                // Get all the keys of the sub dictionary: isGraying, isBold
                var keys: [String] = Array(sub.dictionaryValue.keys)
                
                // Transform the keys to give back as string array and create one string of all the array values
                var transformedValues:[String] = keys.map({ (k:String) -> String in
                    if sub.dictionaryValue[k] == false {
                        return k.stringByReplacingOccurrencesOfString("is", withString: "no", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    }
                    return k
                })
                
                dict[key] = String(", ").join(transformedValues)
            }
            
            return Array(dict.keys).map { [$0:dict[$0]!] }
        }
        
        return nil
    }
    
}





extension MatchCard {
    

    // To make the process of getting data from JSON data slightly more dynamic, let other classes decide what to get from the model
    func getData(fields: [Fields]) -> [Fields:String] {
        
        var returnValue: [Fields:String] = [Fields:String]()
        
        for field: Fields in fields {
            
            let keys:[SubscriptType] = field.getPath()
            var str: String = matchCard[keys].string ?? "-"
            
            //if let error = item[keys].error {
            //println("Error: \(error)")
            //}
            
            if let result: String = customizeField(field, source: str) as? String {
                str = result
            }
            
            returnValue[field] = str
        }
        
        return returnValue
    }
    
    // To just recieve one value, use this method instead
    func getValue(field: Fields) -> String? {
        
        let keys:[SubscriptType] = field.getPath()
        
        var str: String? = matchCard[keys].string
        
        if let s = str {
            if let result: String = customizeField(field, source: s) as? String {
                str = result
            }
        }
        
        return str
    }
    

    private func getJSON(field: Fields, index: Int? = nil) -> JSON {

        let keys:[SubscriptType] = field.getPath()
        var json = matchCard[keys]
        return json
    }
    
}



/* Extension to get specific values from MatchCard */

extension MatchCard {
    
    func getStatus() -> FilterStatusFields? {
        
        let key: [SubscriptType] = Fields.Status.getPath()
        let status = matchCard[key].stringValue
        return FilterStatusFields.allValues[status]
    }
    
    func setStatus(status: FilterStatusFields) {
        
        for (key, val) in FilterStatusFields.allValues {
            if val == status {
                let path: [SubscriptType] = Fields.Status.getPath()
                matchCard[path].string = key
            }
        }
    }
    
    // This gets the matchcard id, not the job ID
    func getID(ID: FieldID) -> String? {
        let key: [SubscriptType] = ID.getPath()
        return matchCard[key].string
    }
    
    func getProfile() -> [String:JSON] {
        let profile: JSON = matchCard[Fields.JobProfile.getPath()]
        return profile.dictionaryValue
    }
    
    func getContract() -> MatchContractType {
        
        var header: [Fields:String?] = [Fields:String?]()
        var details: MatchDetailType = MatchDetailType()
        
        // Header
        header[.ClientAvatar] = getValue(.ClientAvatar) ?? "no avatar"
        header[.ClientCompany] = getValue(.ClientCompany) ?? "-"
        header[.ClientName] = getValue(.ClientName) ?? "-"
        header[.JobTitle] = getValue(.JobTitle) ?? "-"
        header[.JobDescription] = getValue(.JobDescription) ?? "-"
        
        // DATE TIME
        details[.JobContractDateTime] = [[String:String?]]()
        //details[.JobContractDateTime]?.append([ "type" : "type" ])
        details[.JobContractDateTime]?.append([ "dateStart" : getValue(.JobDateStart) ?? "-" ])
        details[.JobContractDateTime]?.append([ "dateEnd" : getValue(.JobDateStart) ?? "-" ])
        details[.JobContractDateTime]?.append([ "timeStart" : getValue(.JobTimeStart) ?? "-" ])
        details[.JobContractDateTime]?.append([ "timeEnd" : getValue(.JobTimeEnd) ?? "-" ])
        
        // LOCATION
        details[.JobContractLocation] = [[String:String?]]()
        details[.JobContractLocation]?.append(["type" : getJSON(.JobContractLocation)["type"].string ])
        details[.JobContractLocation]?.append(["city" : getJSON(.JobContractLocation)["address", "city"].string ?? "-" ])
        details[.JobContractLocation]?.append(["street" : getJSON(.JobContractLocation)["address", "street"].string ?? "-" ])
        details[.JobContractLocation]?.append(["streetNumber" : getJSON(.JobContractLocation)["address", "streetNumber"].string ?? "-" ])
        details[.JobContractLocation]?.append(["zipcode" : getJSON(.JobContractLocation)["address", "zipCode"].string ?? "-" ])
        
        // TRAVEL EXPENSES
        details[.JobPayment] = [[String:String?]]()
        details[.JobPayment]?.append(["budget": customizeField(.JobContractBudget, source: getJSON(.JobContractBudget).intValue) as? String ])
        details[.JobPayment]?.append(["hasTravelExpenses": NSLocalizedString(getJSON(.JobContractTravelExpenses).boolValue.description, comment:"") ])
        details[.JobPayment]?.append(["paymentMethod": getValue(.JobContractPaymentMethod) ?? "-" ])
        
        return (header: header, details: details)
    }
    
    
    // Further customize specific field data
    private func customizeField(field: Fields, source: AnyObject) -> AnyObject? {
        
        switch field {
        case .JobDateStart:
            return (source as! String).ICdateToString(ICDateFormat.Matches)
        case .JobDateEnd:
            return (source as! String).ICdateToString(ICDateFormat.Matches)
        case .JobTimeStart:
            return (source as! String).ICTime()
        case .JobTimeEnd:
            return (source as! String).ICTime()
        case .JobContractBudget:
            return "\((source as! Int) / 1000)"
        default:
            return nil
            
        }
    }
}



