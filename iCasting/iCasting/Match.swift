//
//  Match.swift
//  iCasting
//
//  Created by Tim van Steenoven on 01/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

enum FilterStatusFields: String {
    case // These String values are the localization tokens
    Negotiations    = "NegotiationFilter",
    Pending         = "UnansweredFilter",
    TalentAccepted  = "PendingClientFilter",
    Closed          = "ClosedFilter",
    Completed       = "FinishedFilter"
    
    // The keys are corresponding with the json keys
    static let allValues = [
        "negotiating"       :   Negotiations,   // Accepted by either the client and the talent
        "pending"           :   Pending,        // Unanswered by the talent
        "talent accepted"   :   TalentAccepted, // Accepted by the talent
        "closed"            :   Closed,         // Rejected by the talent
        "completed"         :   Completed       // Match finnished
    ]
}


/* MATCH MODEL */

class Match : NSObject, MatchCardDelegate {
    
    // Contains the original matches from the request, all changes to the matches array must mirror the _matches array
    private var _matches: [MatchCard] = [MatchCard]()

    // Contains the original matches filtered by casting object
    private var matchesFromCastingObject: [MatchCard] {
        get {
            return _matches.filter { (obj) -> Bool in
                return obj.raw["castingObject"].stringValue == User.sharedInstance.castingObjectID
            }
        }
    }
    
    // Contains the filtered matches if there are any filters applied
    var matches: [MatchCard] = [MatchCard]()

    // Contains one match from the matches based on index
    var selectedMatch: MatchCard?
    
    // Contains the selected match index
    private var selectedMatchIndex: Int?
    
    // If the user selects a status, this var will be set
    var currentStatusField: FilterStatusFields?
}




extension Match {
    
    func setMatch(index: Int) {
        
        if index >= 0 && index < matches.endIndex {
            selectedMatch = matches[index]
            selectedMatchIndex = index
            selectedMatch?.delegate = self
        }
    }
    
    private func getMatch(index: Int?) -> MatchCard? {
        
        var item: MatchCard? = selectedMatch
        if let i = index {
            if i >= 0 && i < matches.endIndex {
                item = matches[i]
            }
        }
        return item
    }
    
    // Remove the selected match from the filtered matches and from the original matches collection
    func removeMatch() {
        
        if let selectedMatch = selectedMatch, selectedMatchIndex = selectedMatchIndex {

            var i = 0, found = false
            while found == false && i < _matches.endIndex {
                if _matches[i] == selectedMatch {
                    _matches.removeAtIndex(i)
                    found = true
                }
                i++
            }
            
            matches.removeAtIndex(selectedMatchIndex)
        }
    }
    
    
    // After any updates on the selected match, the the original matches collection needs to reflect these changes as well.
    func mirrorMatch() {
        
        if let selectedMatch = selectedMatch {
            for i in 0..<_matches.endIndex {
                if _matches[i] == selectedMatch {
                    _matches[i] = selectedMatch
                }
            }
        }
        
    }
    
}


// Match delegate

extension Match {
    
    // TIP: If there are more changes that should reflect the main matches, use a proxy or use a general onUpdate delegate method
    func didRejectMatch() {
        println("---- MATCH: Will remove from match model")
        removeMatch()
    }
    
    func didAcceptMatch() {
        println("---- MATCH: Will mirror match model")
        mirrorMatch()
    }
}




extension Match : ModelRequest {
    
    func get(callBack: RequestClosure) {
        
        //self.matches = Dummy.matches.arrayValue
        if let access_token: AnyObject = Auth.auth.access_token {
            
            println("CastingObjectID: "+User.sharedInstance.castingObjectID)
            
            var castingObjectID: String = User.sharedInstance.castingObjectID
            var url: String = APIMatch.MatchCards.value
            var params: [String : AnyObject] = ["access_token":access_token]
            
            request(Method.GET, url, parameters: params, encoding: ParameterEncoding.URL).responseJSON { (_, _, json, error) -> Void in
                
                if let error = error {
                    let errors: ICErrorInfo? = ICError(error: error).getErrors()
                    callBack(failure: errors)
                }
                
                if let json: AnyObject = json {
                    
                    let json = JSON(json)
                    let errors: ICErrorInfo? = ICError(json: json).getErrors()
                    
                    if errors == nil {
                        self.initializeModel(json)
                    }
                    
                    callBack(failure: errors)
                }
            }
            
            return Void()
        }
        
        callBack(failure: nil)
    }
    
    private func initializeModel(json: JSON) {
        self._matches = json.arrayValue.map() { return TalentMatchCard(matchCard: $0) }
        self.filter()
        self.setMatch(0)
    }
    
}

extension Match {
    
    // Filter the matches based on the status of a match, parameter "allExcept" means that the result of the filter will contain everything, except the provided status. If parameter "original" == true, it will filter from the original requested "_matches" global var.
    func filter(field:FilterStatusFields? = nil, allExcept:Bool = false) {
        
        currentStatusField = (allExcept == true) ? nil : field
        
        var mathesToFilter:[MatchCard] = matchesFromCastingObject
        
        if let f = field {
            
            var filtered = mathesToFilter.filter { (obj) -> Bool in
                
                //let path: [SubscriptType] = Fields.Status.getPath()
                //let status = obj[path].stringValue
                
                let status = obj.getStatus()
                
                if allExcept == false {
                    return status == f
                } else {
                    return status != f
                }
            }
            matches = filtered
        }
            
        else {
            
            // If no method parameters are set, go back to the original, all changes in one, should mirror the other, otherwise, you can get unexpected results, reload the data from the server instead.
            matches = matchesFromCastingObject
        }
        
    }
    
}





