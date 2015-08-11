//
//  MatchCard.swift
//  iCasting
//
//  Created by Tim van Steenoven on 15/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

typealias ArrayStringValue = [[String:String]]
typealias ArrayStringStringBool = [[String: [String:Bool]]]

func ==(lhs: MatchCard, rhs: MatchCard) -> Bool {
    return lhs.getID(FieldID.MatchCardID) == rhs.getID(FieldID.MatchCardID)
}

struct ClientProfile {
    var avatar: String?
    var company: String?
    var name: String?
    var employees: String?
    var coc: String?
    var about: String?
}

struct Rating {
    var client: Float?
    var talent: Float?
}

protocol MatchCardObserver: class {
    func didRejectMatch()
    func didAcceptMatch()
    func hasChangedStatus()
}

// The MatchCard class is an object wrapper to expose certain properties and methods for the generic JSON object

final class MatchCard : NSObject, Equatable, Printable, ResponseCollectionSerializable, ResponseObjectSerializable {
    
    internal var matchCard: JSON = JSON("")
    private let contract: [SubscriptType] = FieldRoots.RootJobContract.getPath()
    internal let profileRoot: [SubscriptType] = FieldRoots.RootJobProfile.getPath()
    private var titles: [String] = [String]()
    private var profile: [ArrayStringValue] = [ArrayStringValue]()
    
    //----- Experiment
    var job: Job?
    //----------------
    
    weak var observer: MatchCardObserver?
    
    var raw: JSON { return matchCard }
    
    
//    override var description: String {
//        return profile.description
//    }
    
    
//    subscript(index: Int) -> ArrayStringValue {
//        return profile[index]
//    }
    
    
    // Init
    init(matchCard: JSON) {
        super.init()
        
        self.matchCard = matchCard
        //let include = [profileHair, profileFirstLevel, profileLanguage, profileNear]
        //self.profile = filterArrayForNil(include)
    }
    
    // ResponseObjectSerializable
    
    init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.matchCard = JSON(representation)
        self.job = Job(source: self.matchCard)
    }
    
    // ResponseCollectionSerializable
    
    static func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [MatchCard] {
        
        var list = [MatchCard]()
        if let representation = representation as? [AnyObject] {
            list = representation.map() { return MatchCard(matchCard: JSON($0)) }
        }
        return list
    }
    

    func getStatus() -> FilterStatusFields? {
        
        let path: [SubscriptType] = Fields.Status.getPath()
        let status = matchCard[path].stringValue
        println("status: "+status)
        return FilterStatusFields.allValues[status]
    }
    
    
    func setStatus(status: FilterStatusFields) {
        
        for (key, val) in FilterStatusFields.allValues {
            if val == status {
                let path: [SubscriptType] = Fields.Status.getPath()
                matchCard[path].string = key
                
                observer?.hasChangedStatus()
            }
        }
    }
    
    var hasRead: Bool {
        
        let path = Fields.Read.getPath()
        return raw[path].boolValue
    }
    
    
    // A convenient shortcut to see if the talent has already rated yet
    var talentHasRated: Bool {
        
        if let rating = self.rating {
            if let talent = rating.talent {
                return true
            }
        }
        return false
    }
    
    
    // Get the rating of the client and talent
    var rating: Rating? {
    
        let talent = "talent"
        let client = "client"
        
        if let ratedBy = raw["ratedBy"].dictionary {
            return Rating(
                client: ratedBy[client]?.float,
                talent: ratedBy[talent]?.float
            )
        }
        
        return nil
    }
    
    
    // This is local and will represent a change in the model data temporarely. Only call this method if you are sure that the server data has been updated
    func setLocalTalentRating(grade: Float) {
        
        if let ratedBy = raw["ratedBy"].dictionary {
            matchCard["ratedBy"]["talent"].float = grade
        } else {
            matchCard["ratedBy"] = JSON(["talent":grade])
        }
    }
    
    
    
    // Test methods
    
    func testDecision(decision: DecisionState, callBack: RequestClosure) {
        // Before doing a success callback to the controller, first let observers know
        if decision == DecisionState.Accept {
            testAccept(callBack)
        } else {
            testReject(callBack)
        }
    }
    
    func testAccept(callBack: RequestClosure) {
        self.setStatus(FilterStatusFields.TalentAccepted)
        observer?.hasChangedStatus()
        callBack(failure: nil)
    }
    
    func testReject(callBack: RequestClosure) {
        observer?.didRejectMatch()
        callBack(failure: nil)
    }
    
    func testError(callBack: RequestClosure) {
        var errorInfo: ICErrorInfo? = ICError(json: JSON("test")).errorInfo
        callBack(failure: errorInfo)
    }
}