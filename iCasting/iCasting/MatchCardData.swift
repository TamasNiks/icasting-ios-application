//
//  MatchCardData.swift
//  iCasting
//
//  Created by Tim van Steenoven on 05/08/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// Extension to retrieve data based on specified Fields or subscript types

extension MatchCard {
    
    func getData(fields: [Fields]) -> [Fields:String] {
        var returnValue: [Fields:String] = [Fields:String]()
        for field: Fields in fields {
            let path:[SubscriptType] = field.getPath()
            var str: String = matchCard[path].string ?? "-"
            returnValue[field] = str
        }
        return returnValue
    }
    
    func getValue(field: Fields) -> String? {
        let keys:[SubscriptType] = field.getPath()
        return matchCard[keys].string
    }
    
    func getValue(path: [SubscriptType]) -> String? {
        return matchCard[path].string
    }
    
    func getJSON(path: [SubscriptType]) -> JSON {
        return matchCard[path]
    }
    
    private func getJSON(field: FieldPathProtocol) -> JSON {
        let keys:[SubscriptType] = field.getPath()
        return matchCard[keys]
    }
    
    private func getJSON(field: Fields) -> JSON {
        let keys:[SubscriptType] = field.getPath()
        return matchCard[keys]
    }
}



// Extension to get specific values from MatchCard

//typealias ArrayDictionaryType = [[String:String]]
typealias MatchStaticFieldType = [Fields:String?]
typealias MatchDynamicFieldType = [Fields: StringDictionaryArray] // Dictionary with Fields key and a an array of Dictionaries of type String key values
typealias MatchDetailType = (general: MatchStaticFieldType, details: MatchDynamicFieldType)

extension MatchCard {
    
    var clientProfile: ClientProfile? {
        
        let root = getJSON(["job", "owner", "company"])
        
        return ClientProfile(
            avatar      : nil,
            company     : root["name"].string,
            name        : nil,
            employees   : root["size"].string,
            coc         : root["COC"].string,
            about       : root["aboutUs"].string)
    }
    
    var avatar: String {
        return getValue(Fields.ClientAvatar) ?? String()
    }
    
    var title: String {
        return getValue(Fields.JobTitle) ?? "-"
    }
    
    var talent: String {
        return matchCard[profileRoot]["type"].string ?? "-"
    }
    
    var dateStart: String {
        return MatchValueExtractor.Date(getValue(.JobDateStart)).modify() ?? "-"
    }
    
    var typeTalent: String {
        var stringArray = matchCard[profileRoot][talent].arrayValue.map { $0.stringValue }
        return String(", ").join(stringArray)
    }
    
    var gender: String? {
        if let g = matchCard[profileRoot]["gender"].string {
            var prefix = "matches.details.gender.%@"
            return NSLocalizedString(String(format: prefix, g), comment: "Match card desciprtion of gender")
        }
        return nil
    }
    
    var ageMinimum: String? {
        return MatchValueExtractor.Age(matchCard[profileRoot]["age"]["minimum"].string).modify()
    }
    
    var ageMaximum: String? {
        return MatchValueExtractor.Age(matchCard[profileRoot]["age"]["maximum"].string).modify()
    }
    
    func getID(ID: FieldID) -> String? {
        let key: [SubscriptType] = ID.getPath()
        return matchCard[key].string
    }
    
    func getProfile() -> [String:JSON] {
        let profile: JSON = matchCard[Fields.JobProfile.getPath()]
        return profile.dictionaryValue
    }
}



// An extension to get related values grouped together

extension MatchCard {
    
    var general: MatchStaticFieldType {
        
        var header: [Fields:String?] = [Fields:String?]()
        header[.ClientAvatar]   =   getValue(.ClientAvatar)
        header[.ClientCompany]  =   getValue(.ClientCompany) ?? "-"
        header[.ClientName]     =   getValue(.ClientName) ?? "-"
        header[.JobTitle]       =   getValue(.JobTitle) ?? "-"
        header[.JobDescLong]    =   getValue(.JobDescLong) ?? "-"
        return header
    }
    
    var dateTime: StringDictionaryArray {
        
        let root = getJSON(.JobDateTime)
        var value = [[String:String?]]()
        value.append([ "type"     :   root["type"].string ])
        value.append([ "dateStart":   dateStart ])
        value.append([ "dateEnd"  :   MatchValueExtractor.Date(root["dateEnd"].string).modify() ])
        value.append([ "timeStart":   root["timeStart"].string ])
        value.append([ "timeEnd"  :   root["timeEnd"].string ])
        return filterDictionaryInArrayForNil(value)
    }
    
    var location: StringDictionaryArray {
        
        let root = getJSON(.JobContractLocation)
        var value = [[String:String?]]()
        value.append(["type"          :    root["type"].string ])
        value.append(["city"          :    root["address", "city"].string ])
        value.append(["street"        :    root["address", "street"].string ])
        value.append(["streetNumber"  :    root["address", "streetNumber"].string ])
        value.append(["zipcode"       :    root["address", "zipCode"].string ])
        return filterDictionaryInArrayForNil(value)
    }
    
    var payment: StringDictionaryArray {
        
        let root = getJSON(FieldRoots.RootJobContract)
        var value = [[String:String?]]()
        value.append(["budget"             : MatchValueExtractor.Budget(root["budget", "times1000"].intValue).modify() ])
        value.append(["hasTravelExpenses"  : MatchValueExtractor.Boolean(root["travelExpenses", "hasTravelExpenses"].boolValue).modify() ])
        value.append(["paymentMethod"      : root["paymentMethod", "type"].string ])
        return filterDictionaryInArrayForNil(value)
    }
    
    var specific: StringDictionaryArray {
        
        var value = [[String:String?]]()
        value.append(["typeTalent" : typeTalent])
        value.append(["gender"     : gender])
        value.append(["ageMinimum" : ageMinimum])
        value.append(["ageMaximum" : ageMaximum])
        return filterDictionaryInArrayForNil(value)
    }
    
    func getOverview() -> MatchDetailType {
        
        var details = MatchDynamicFieldType()
        details.updateValue(dateTime, forKey: .JobDateTime)
        details.updateValue(location, forKey: .JobContractLocation)
        details.updateValue(payment,  forKey: .JobPayment)
        return (general: general, details: details)
    }
    
}



// EXPERIMENT: Experimenting for a convenient way of getting dynamic profile data

/*

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

*/