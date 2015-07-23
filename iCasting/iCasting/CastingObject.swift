//
//  CastingObject.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

protocol ValueProvider {
    typealias ValueType
    var values: ValueType {get}
}

final class CastingObject : ValueProvider, ResponseCollectionSerializable {

    struct XPlog {
        let xp: Int
        let desc: String
        let achievement: String
        let date: String
        let id: String
    }
    
    struct Stats {
        let videosUploaded: Int
        let matches: Int
        let jobsCompleted: Int
        let castingCardsCreated: Int
        let videoReactionsSent: Int
        let reactionsSent: Int
    }
    
    struct Counters {
        let profileImages: Int
        let profileVideos: Int
        let videoReactions: Int
        let reactions: Int
    }
    
    struct AchievementsProgress {
        let completed: Bool
        let completedDate: String
        let created: String
        let id: String
    }
    
    struct Values : Printable {
        let stats: Stats
        let xplog: [XPlog]
        let counters: Counters
        let achievementsProgress: [AchievementsProgress]
//        let id: String
//        let avatar: String
//        let name: String
//        let experience: String
//        let profileLevel: String
//        let jobRating: String
        
        var description: String {
            return ""
            //return "id: \(id), name: \(name), experience: \(experience), profileLevel: \(profileLevel), jobRating: \(jobRating)"
        }
    }
    
    private let castingObject: JSON
    private var castingObjectValues: Values? // = Values(id: "", avatar: "", name: "", experience: "", profileLevel: "", jobRating: "")
    
    var values: Values {
        return castingObjectValues!
    }
    
    init(json: JSON) {
        
        self.castingObject = json

        let stats = Stats(
            videosUploaded:     self.castingObject["stats"]["videosUploaded"].intValue,
            matches:            self.castingObject["stats"]["matches"].intValue,
            jobsCompleted:      self.castingObject["stats"]["jobsCompleted"].intValue,
            castingCardsCreated:self.castingObject["stats"]["castingCardsCreated"].intValue,
            videoReactionsSent: self.castingObject["stats"]["videoReactionsSent"].intValue,
            reactionsSent:      self.castingObject["stats"]["reactionsSent"].intValue
        )
  
        var xplog: [XPlog] = self.castingObject["xpLog"].arrayValue.map({ (transform: JSON) -> CastingObject.XPlog in
            return XPlog(
                xp:         transform["xp"].intValue,
                desc:       transform["desc"].stringValue,
                achievement:transform["achievement"].stringValue,
                date:       transform["date"].stringValue,
                id:         transform["id"].stringValue
            )
        })
        
        let counters = Counters(
            profileImages:  self.castingObject["counters"]["profileImages"].intValue,
            profileVideos:  self.castingObject["counters"]["profileVideos"].intValue,
            videoReactions: self.castingObject["counters"]["videoReactions"].intValue,
            reactions:      self.castingObject["counters"]["reactions"].intValue)

        
        var achievementsProgress: [AchievementsProgress] = self.castingObject["achievementsProgress"].arrayValue.map({ (transform: JSON) -> CastingObject.AchievementsProgress in
            return AchievementsProgress(
                completed:      transform["completed"].boolValue,
                completedDate:  transform["completedDate"].stringValue,
                created:        transform["created"].stringValue,
                id:             transform["id"].stringValue
            )
        })
        
        self.castingObjectValues = Values(stats: stats, xplog: xplog, counters: counters, achievementsProgress: achievementsProgress)
        
        
        
//        self.castingObjectValues = Values(
//            id:             self.castingObject["_id"].string!,
//            avatar:         self.castingObject["avatar"]["thumb"].string!,
//            name:           self.castingObject["name"]["full"].string ?? "-",
//            experience:     String(stringInterpolationSegment: self.castingObject["xp"]["total"].intValue),
//            profileLevel:   self.castingObject["name"]["display"].string ?? "-",
//            jobRating:      String(stringInterpolationSegment: self.castingObject["xp"]["jobRating"].intValue)
//        )
    }
    
    init() {
        self.castingObject = JSON("")
    }
    
    @objc static func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [CastingObject] {
        
        let json = JSON(representation)
        var castingObjects:[CastingObject] = json.arrayValue.map { CastingObject(json: $0) }
        return castingObjects
    }
    
    
    var id: String? {
        return self.castingObject["_id"].string
    }
    
    var avatar: String? {
        return self.castingObject["avatar"]["thumb"].string
    }
    
    var name: String? {
        return self.castingObject["name"]["full"].string ?? "-"
    }
    
    var experience: String? {
        let val: Int? = self.castingObject["xp"]["total"].int
        return (val == nil) ? "-" : "\(val!)"
    }
    
    var profileLevel: String? {
        return self.castingObject["name"]["display"].string ?? "-"
    }
    
    var jobRating: String? {
        let val: Int? = self.castingObject["jobRating"].int
        if let v = val {
            return "\(v)"
        }
        return "-"
    }

//    func summary() -> CastingObjectSummary {
//        
//    }
    
}


class CastingObjectRequest: RequestCommand {
    func execute(callBack:LoginClosure) {
        (CastingObject() as ModelRequest).get { (failure) -> () in
            callBack(failure: failure)
        }
    }
}
