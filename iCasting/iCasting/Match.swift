//
//  Match.swift
//  iCasting
//
//  Created by Tim van Steenoven on 01/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

protocol FieldPathProtocol {
    func getPath() -> [SubscriptType]
}


private enum FieldRoots: Int, FieldPathProtocol {
    case RootJobContract, RootJobProfile
    
    func getPath() -> [SubscriptType] {
        switch self {
        case .RootJobContract:
            return ["job", "formSource", "contract"]
        case .RootJobProfile:
            return ["job", "formSource", "profile"]
        }
    }
}

enum FieldID: Int, FieldPathProtocol {
    case MatchCardID, JobID
    
    func getPath() -> [SubscriptType] {
        switch self {
        case .MatchCardID:
            return ["_id"]
        case .JobID:
            return ["job","_id"]
        }
    }
}

enum Fields: Int, FieldPathProtocol {

    case Status
    case ClientName, ClientCompany, ClientAvatar
    case JobTitle, JobDescription
    case JobContractDateTime, JobDateStart, JobDateEnd, JobTimeStart, JobTimeEnd
    case JobContractLocation
    case JobProfile
    case JobPayment, JobContractPaymentMethod, JobContractBudget, JobContractTravelExpenses
    
    func getPath() -> [SubscriptType] {
        switch self {
        case .Status:
            return ["status"]
        case .ClientName:
            return ["client","name","display"]
        case .ClientCompany:
            return ["client","company","name"]
        case .ClientAvatar:
            return ["client","avatar","thumb"]
        case .JobTitle:
            return ["job","title"]
        case .JobDescription:
            return ["job","desc"]
        case .JobDateStart:
            return ["job", "formSource", "contract", "dateTime", "dateStart"]
        case .JobDateEnd:
            return ["job", "formSource", "contract", "dateTime", "dateEnd"]
        case .JobTimeStart:
            return ["job", "formSource", "contract", "dateTime", "timeStart"]
        case .JobTimeEnd:
            return ["job", "formSource", "contract", "dateTime", "timeEnd"]
        case .JobContractLocation:
            return ["job", "formSource", "contract", "location"]
        case .JobContractPaymentMethod:
            return ["job", "formSource", "contract", "paymentMethod", "type"]
        case .JobContractBudget:
            return ["job", "formSource", "contract", "budget", "times1000"]
        case .JobContractTravelExpenses:
            return ["job", "formSource", "contract", "travelExpenses", "hasTravelExpenses"]
        case .JobProfile:
            return FieldRoots.RootJobProfile.getPath()
        default:
            return []
        }
    }
    
    var header: String {
        switch self {
        case .JobContractDateTime:
            return NSLocalizedString("dateTime", comment: "Header text for all the time properties")
        case .JobContractLocation:
            return NSLocalizedString("location", comment: "Header text for all the location properties")
        case .JobContractTravelExpenses:
            return NSLocalizedString("travelExpenses", comment: "Header text for all the travelexpenses properties")
        case .JobPayment:
            return NSLocalizedString("payment", comment: "Header text for all the travelexpenses properties")
        default:
            return "To developer: No header"
        }
    }
}

enum FilterStatusFields: Int {
    case Negotiations, Pending, TalentAccepted, Closed
    static let allValues = ["negotiating":Negotiations, "pending":Pending, "talent accepted":TalentAccepted, "closed": Closed]
}

// Convenient shortcut to get all the detail values
typealias MatchHeaderType = [Fields:String?]
typealias MatchDetailType = [Fields: [ [String:String?] ] ] // Dictionary with Fields key and a an array of Dictionaries of type String key values
typealias MatchDetailsReturnValue = (header: MatchHeaderType, details: MatchDetailType)


/* MATCH MODEL */

class Match {
    
    // Contains the original matches from the request
    private var _matches: [JSON] = [JSON]()
    
    // Contains the filtered matches if there are any filters applied
    var matches: [JSON] = [JSON]()

    // Contains one match from the matches based on index
    var selectedMatch: JSON?
    
    // TODO: It is safer to do the comparisons by match id than index id, for now it is more convenient
    private var selectedMatchIndex: Int?

}

extension Match {
    
    func all(callBack: ()->()) {
        
        //self.matches = Dummy.matches.arrayValue
        
        var url: String = APIMatch.MatchCards.value
        var access_token: AnyObject = Auth.auth.access_token as! AnyObject
        var params: [String : AnyObject] = ["access_token":access_token]
        
        request(Method.GET, url, parameters: params, encoding: ParameterEncoding.URL).responseJSON { (_, _, json, _) -> Void in
            
            if let j: AnyObject = json {
                self._matches = JSON(j).arrayValue
                self.filter()
                self.setMatch(0)
                callBack()
            }
        }
    }
    
    // Because the matches will be an array, you can set a specific match based on it's index
    func setMatch(index: Int) {
        if index >= 0 && index < matches.endIndex {
            selectedMatch = matches[index]
            selectedMatchIndex = index
        }
    }
    
    func removeMatch() {
        if let index = selectedMatchIndex {
            matches.removeAtIndex(index)
        }
    }
    
    // Filter the matches based on the status of a match, allExcept means that the result of the filter will not contain the provided status. If original is true, it will filter the original requested matches.
    func filter(field:FilterStatusFields? = nil, allExcept:Bool = false, original:Bool = true) {
        
        var mathesToFilter:[JSON] = _matches
        
        if original == false {
            mathesToFilter = matches
        }
        
        if let f = field {
            var filtered = mathesToFilter.filter { (obj) -> Bool in
                
                let key: [SubscriptType] = Fields.Status.getPath()
                let status = obj[key].stringValue
                
                if allExcept == false {
                    if FilterStatusFields.allValues[status] == f {
                        return true
                    }
                    return false
                } else {
                    if FilterStatusFields.allValues[status] != f {
                        return true
                    }
                    return false
                }
            }
            
            matches = filtered
        }
        else {
            // If no method parameters are set, go back to the original, it is actually better to reload the data from the server
            matches = _matches
        }
    }
    
}

// Generic extension methods to extract values from a match
extension Match {
    
    // To make the process of getting data from JSON data slightly more dynamic, let other classes decide what to get from the model
    func getMatchData(fields: [Fields], index: Int? = nil) -> [Fields:String] {
        
        let item = getRightMatch(index)
        
        var returnValue: [Fields:String] = [Fields:String]()
        
        for field: Fields in fields {
            
            let keys:[SubscriptType] = field.getPath()
            var str: String = item[keys].string ?? "-"
            
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
    func getMatchValue(field: Fields, index: Int? = nil) -> String? {
        
        let item = getRightMatch(index)
        
        let keys:[SubscriptType] = field.getPath()
        
        var str: String? = item[keys].string
        
        //if let error = item[keys].error {
        //println("Error: \(error)")
        //}
        
        
        if let s = str {
            if let result: String = customizeField(field, source: s) as? String {
                str = result
            }
        }
        
        return str
    }
    
    private func getMatchJSON(field: Fields, index: Int? = nil) -> JSON {
        let item = getRightMatch(index)
        let keys:[SubscriptType] = field.getPath()
        var json = item[keys]
        return json
    }
    
    private func getRightMatch(index: Int?) -> JSON {
        var item: JSON = selectedMatch!
        if let i = index {
            if i >= 0 && i < matches.endIndex {
                item = matches[i]
            }
        }
        return item
    }
    
}


// Extension to get specific values from Match
extension Match {
    
    func getStatus() -> FilterStatusFields? {
        
        if let sm = selectedMatch {
            let key: [SubscriptType] = Fields.Status.getPath()
            let status = sm[key].stringValue
            return FilterStatusFields.allValues[status]
        }
        return nil
    }

    func setStatus(status: FilterStatusFields) {
        
        if let sm = selectedMatch {
            let key: [SubscriptType] = Fields.Status.getPath()
            for (str, val) in FilterStatusFields.allValues {
                if val == status {
                    selectedMatch![key].string = str
                    // After changing it to the selected match, update the matches as well with the selectedMatch.
                    matches[selectedMatchIndex!] = selectedMatch!
                }
            }
        }
    }

    // This gets the matchcard id, not the job ID
    func getID(ID: FieldID) -> String? {
        
        let key: [SubscriptType] = ID.getPath()
        if let sm = selectedMatch {
            return sm[key].string
        }
        return nil
    }
    
    func getProfile(index:Int? = nil) -> [String:JSON] {
        
        let item = getRightMatch(index)
        let profile: JSON = item[Fields.JobProfile.getPath()]
        return profile.dictionaryValue
    }
    
    // TODO: Because the model is not responsible for the view display, the structure of data for the view should go to the controller
    func getMatchDetails() -> MatchDetailsReturnValue {
        
        var header: [Fields:String?] = [Fields:String?]()
        var details: MatchDetailType = MatchDetailType()
        
        if selectedMatch?.count > 0 {
            
            header[.ClientAvatar] = "lala"
            
            // Header
            header[.ClientAvatar] = getMatchValue(.ClientAvatar) ?? "no avatar"
            header[.ClientCompany] = getMatchValue(.ClientCompany) ?? "-"
            header[.ClientName] = getMatchValue(.ClientName) ?? "-"
            header[.JobTitle] = getMatchValue(.JobTitle) ?? "-"
            header[.JobDescription] = getMatchValue(.JobDescription) ?? "-"
            
            // DATE TIME
            details[.JobContractDateTime] = [[String:String?]]()
            //details[.JobContractDateTime]?.append([ "type" : "type" ])
            details[.JobContractDateTime]?.append([ "dateStart" : getMatchValue(.JobDateStart) ?? "-" ])
            details[.JobContractDateTime]?.append([ "dateEnd" : getMatchValue(.JobDateStart) ?? "-" ])
            details[.JobContractDateTime]?.append([ "timeStart" : getMatchValue(.JobTimeStart) ?? "-" ])
            details[.JobContractDateTime]?.append([ "timeEnd" : getMatchValue(.JobTimeEnd) ?? "-" ])
            
            // LOCATION
            details[.JobContractLocation] = [[String:String?]]()
            details[.JobContractLocation]?.append(["type" : getMatchJSON(.JobContractLocation)["type"].string ])
            details[.JobContractLocation]?.append(["city" : getMatchJSON(.JobContractLocation)["address", "city"].string ])
            details[.JobContractLocation]?.append(["street" : getMatchJSON(.JobContractLocation)["address", "street"].string ])
            details[.JobContractLocation]?.append(["streetNumber" : getMatchJSON(.JobContractLocation)["address", "streetNumber"].string ])
            details[.JobContractLocation]?.append(["zipcode" : getMatchJSON(.JobContractLocation)["address", "zipCode"].string ])

            // TRAVEL EXPENSES
            details[.JobPayment] = [[String:String?]]()
            details[.JobPayment]?.append(["budget": customizeField(.JobContractBudget, source: getMatchJSON(.JobContractBudget).intValue) as? String ])
            details[.JobPayment]?.append(["hasTravelExpenses": NSLocalizedString(getMatchJSON(.JobContractTravelExpenses).boolValue.description, comment:"") ])
            details[.JobPayment]?.append(["paymentMethod": getMatchValue(.JobContractPaymentMethod) ?? "-" ])

            
            //let profileData: [String:JSON] = self.getProfile()
            
            //details[.JobProfile] //?//.append(profileData)
            
            println(details[.JobContractDateTime])
            println(details[.JobContractLocation])
            println(details[.JobPayment])
        }
        
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



/* A specialized model class for talents */

class TalentMatch: Match {
    
    //TODO: These methods are very similar, so it might be better to make it one method
    
    func accept(callBack:RequestClosure) {
        
        if let ID = super.getID(FieldID.MatchCardID) {
        
            var url: String = APIMatch.MatchAcceptTalent(ID).value
            var access_token: AnyObject = Auth.auth.access_token as! AnyObject
            var params: [String : AnyObject] = ["access_token":access_token]
            
            // Test
            //var errorInfo: ICErrorInfo? = ICError(json: JSON("test")).getErrors()
            //callBack(failure: errorInfo)

            request(.POST, url, parameters: params).responseJSON() { (request, response, json, error) in
                
                if (error != nil) {
                    NSLog("Error: \(error)")
                    println(request)
                    println(response)
                }
                
                if let json: AnyObject = json {
                    
                    let parsedJSON = JSON(json)
                    var errorInfo: ICErrorInfo? = ICError(json: parsedJSON).getErrors()
                    callBack(failure: errorInfo)
                }
                
                println(response)
                println(json)
                
            }
        }
    }
    
    func reject(callBack:RequestClosure) {
        
        if let ID = super.getID(FieldID.MatchCardID) {
            
            var url: String = APIMatch.MatchRejectTalent(ID).value
            var access_token: AnyObject = Auth.auth.access_token as! AnyObject
            var params: [String : AnyObject] = ["access_token":access_token]
            
            // Test
            //var errorInfo: ICErrorInfo? = ICError(json: JSON("test")).getErrors()
            //callBack(failure: errorInfo)
            
            request(.POST, url, parameters: params).responseJSON() { (request, response, json, error) in
                
                if (error != nil) {
                    NSLog("Error: \(error)")
                    println(request)
                    println(response)
                }
                
                if let json: AnyObject = json {
                    
                    let parsedJSON = JSON(json)
                    var errorInfo: ICErrorInfo? = ICError(json: parsedJSON).getErrors()
                    callBack(failure: errorInfo)
                }
                
                println(response)
                println(json)
                
            }
        }
    }
}