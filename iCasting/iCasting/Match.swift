//
//  Match.swift
//  iCasting
//
//  Created by Tim van Steenoven on 23/04/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

//func +(stringArray1:[String:String], stringArray2:[String:String]) {
//    
//}


enum FieldRoots: String {
    case JobFormSource = "formSource", Client = "client"
}

enum Fields: Int {
    case ClientCompany, ClientName, JobTitle, JobDescription
    case JobContractDateTime, JobContractLocation, JobContractTravelExpenses
    
    struct Path {
        let path: [String]
    }
    
    func getPath() -> Path {
        
        switch self {
        case .ClientCompany:
            return Path(path: ["client","company","name"])
        case .ClientName:
            return Path(path: ["client","name","display"])
        case .JobTitle:
            return Path(path: ["job","title"])
        case .JobDescription:
            return Path(path: ["job","desc"])
        case .JobContractDateTime:
            return Path(path: ["job","formSource","contract","dateTime"])
        case .JobContractLocation:
            return Path(path: ["job","formSource","contract","location"])
        case .JobContractTravelExpenses:
            return Path(path: ["job","formSource","contract","travelExpenses"])
        }
    }
}



class Match : ModelProtocol  {
    
    // Make it private
    var matches: NSArray {
        get {return _matches}
    }
    
    var currentMatch: NSDictionary {
        get {return _currentMatch}
    }
    
    var _matches: NSArray = NSArray()
    var _currentMatch: NSDictionary = NSDictionary()

    func all(callBack: RequestClosure) {
        
        self._matches = (Dummy.matches as? NSArray)!
        
        var url: String = APIMatch.MatchCards.value
        var access_token: AnyObject = User.sharedInstance.auth.access_token as! AnyObject
        var params: [String : AnyObject] = ["access_token":access_token]

        request(Method.GET, url, parameters: params, encoding: ParameterEncoding.URL).responseJSON { (_, _, JSON, _) -> Void in
            
            if let json: AnyObject = JSON {
                self._matches = json as! NSArray
                callBack((success:"SUCCESS", failure:nil))
            }
        }
    }
    
    
    
    func one(id: String, callBack: RequestClosure) {
        
        if self._matches.count > 0 {
            
            for obj in self._matches {
                if (obj as! NSDictionary).objectForKey("job")?.objectForKey("_id") as! String == id {
                    callBack((success:obj, failure:nil))
                    return
                }
            }
            
            
        }
    }
    

    
}




typealias MatchDetailType = [Fields:[[String:String]]]
typealias MatchDetailsReturnValue = (header: [Fields:String?], details: MatchDetailType)


struct MatchData: Printable {
    let company: String
    let name: String
    let title: String
    let desc: String
}

extension MatchData {
    var description: String {return " "}
}

extension Match {
    
    func getFields([Fields]) -> NSDictionary {
     
        return NSDictionary()
    }
    
    
    func getMatch(index: Int) -> NSDictionary {
        
        if matches.count > 0 && index < matches.count {
            return matches[index] as! NSDictionary
        }
        return NSDictionary()
    }
    
    func setMatch(index: Int) {
        
        if matches.count > 0 && index < matches.count {
            _currentMatch = matches[index] as! NSDictionary
        }

    }
    
    
    func getMatchDetails() -> MatchDetailsReturnValue {
        
        var header: [Fields:String?] = [Fields:String?]()
        //var details: [Fields:Printable] = [Fields:Printable]()
        var details: MatchDetailType = MatchDetailType()
        
        if currentMatch.count > 0 {
            
            // TODO: To make it more efficient, try to search for more patchs fields at once.
            
//            struct ICDateTime : Printable {
//                let type: String?
//                let dateStart: String?
//                let timeStart : String?
//                let timeEnd: String?
//                var description : String {return "ICDateTime { type = \(type), dateStart = \(dateStart), timeStart = \(timeStart), timeEnd = \(timeEnd)"}
//            }
//            
//            struct ICLocation : Printable {
//                let type: String?
//                let city: String?
//                let street : String?
//                let streetNumber: String?
//                let zipCode : String?
//                var description : String {return "ICLocation { type = \(city), city = \(street), street = \(street), streetNumber = \(streetNumber) zipCode = \(zipCode)"}
//            }
//
//            struct ICTravelExpenses : Printable {
//                let hasTravelExpenses: Bool?
//                var description : String {return "ICTravelExpenses { hasTravelExpenses = \(hasTravelExpenses)"}
//            }
            
            
            // Header
            let company: String? = JSONSearchFacade.stringSearch(source: currentMatch, fields: .ClientCompany)
            let name: String? = JSONSearchFacade.stringSearch(source: currentMatch, fields: .ClientName)
            let title: String? = JSONSearchFacade.stringSearch(source: currentMatch, fields: .JobTitle)
            let description: String? = JSONSearchFacade.stringSearch(source: currentMatch, fields: .JobDescription)

            
            // Details
//            let root: [String:AnyObject] = currentMatch as! [String:AnyObject]
//            let rootContract = dictionary(root, "job") >>>= {dictionary($0, "formSource") >>>= {dictionary($0, "contract") }}
//            let rootProfile = dictionary(root, "job") >>>= {dictionary($0, "formSource") >>>= {dictionary($0, "profile") }}
//
//            var dateTime: [String : AnyObject]? = rootContract >>>= { dictionary($0, "dateTime") }
//            var location: [String : AnyObject]? = rootContract >>>= { dictionary($0, "location") }
//            var travelExpense: [String : AnyObject]? = rootContract >>>= { dictionary($0, "travelExpenses") }
            
//            details[.JobContractDateTime] = ICDateTime (
//                type:           (dateTime >>>= { string($0, "type") }) ?? "no date",
//                dateStart:      (dateTime >>>= { string($0, "dateStart") }) ?? "no start date",
//                timeStart:      (dateTime >>>= { string($0, "timeStart") }) ?? "no start time",
//                timeEnd:        (dateTime >>>= { string($0, "timeEnd") }) ?? "no time end"
//            )

//            details[.JobContractDateTime] = [
//                ["type":           dateTime >>>= { string($0, "type") }],
//                ["dateStart":      dateTime >>>= { string($0, "dateStart") }],
//                ["timeStart":      dateTime >>>= { string($0, "timeStart") }],
//                ["timeEnd":        dateTime >>>= { string($0, "timeEnd") }]
//            ]
            
//            details[.JobContractLocation] = ICLocation (
//                type:           location >>>= { string($0, "type") },
//                city:           location >>>= { dictionary($0, "address") >>>= { string($0, "city") }},
//                street:         location >>>= { dictionary($0, "address") >>>= { string($0, "street") }},
//                streetNumber:   location >>>= { dictionary($0, "address") >>>= { string($0, "streetNumber") }},
//                zipCode:        location >>>= { dictionary($0, "address") >>>= { string($0, "zipCode") }}
//            )
//            
//            details[.JobContractTravelExpenses] = ICTravelExpenses(
//                hasTravelExpenses: travelExpense >>>= { bool($0, "hasTravelExpenses") }
//            )
            
//            println(details[.JobContractDateTime])
//            
//            println(details[.JobContractLocation])
//
//            println(details[.JobContractTravelExpenses])
            

            header = [.ClientCompany: company, .ClientName: name, .JobTitle: title, .JobDescription: description]
        }
        
        return (header: header, details: details)
    }
    
    // The cell info is based on the current match or on the
    func getCellInfo(index: Int? = nil) -> [String:String] {

        var item: NSDictionary = NSDictionary()
        
        if let i = index {
            if matches.count > 0 && i < matches.count {
                item = _matches[i] as! NSDictionary
                var title: String = (item.objectForKey("job") as! NSDictionary).objectForKey("title") as! String
                var desc: String = (item.objectForKey("job") as! NSDictionary).objectForKey("desc") as! String
                return ["title": title, "description": desc]
            }
        }

        return [String:String]()
    }
    
    
}

    



extension Match {
    
    
    private func getDeepestObject(d: NSDictionary, inout c:NSMutableArray) -> NSDictionary? {
        
        var col: NSMutableArray = NSMutableArray()
        for (key, val) in d {
            if val is NSDictionary {
                col.addObject(val)
            }
        }
        for val in col {
            c.addObject(getDeepestObject(val as! NSDictionary, c: &c)!)
        }
        return d
    }
    

    
    
}