//
//  MatchDetailJSONParser.swift
//  iCasting
//
//  Created by Tim van Steenoven on 28/04/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

class RootJSONParser {

    var source: [String:AnyObject]?
    
    init(source: [String:AnyObject]) {
        self.source = source
    }
    
    func parseJSON() {
        
        if let source = self.source {
            let contract = dictionary(source, "job") >>>= {dictionary($0, "formSource") >>>= {dictionary($0, "contract") >>>= {$0}}}
            let profile = dictionary(source, "job") >>>= {dictionary($0, "formSource") >>>= {dictionary($0, "profile") >>>= {$0}}}
        }
        
    }
}

class MatchDetailJSONParser {
    
    struct TimeLocation {
        let type: String
        let dateStart: String
        let timeStart : String
        let timeEnd: String
    }

    func parse(blog: AnyObject) -> TimeLocation? {
        
        let mkStruct = curry { type, dateStart, timeStart, timeEnd in
            TimeLocation(type: type, dateStart: dateStart, timeStart: timeStart, timeEnd: timeEnd)
        }
        
        return asDict(blog) >>>= {
            mkStruct <*> string($0,"type")
                <*> string($0,"dateStart")
                <*> string($0,"timeStart")
                <*> string($0, "timeEnd")
        }
    }
    
    func parseJSON(#source: [String:AnyObject]) {
        
        let paths: [String] = Fields.JobContractDateTime.getPath().path
        
        let blogs = dictionary(source, "blogs") >>>= {
            array($0, "blog") >>>= {
                join($0.map(self.parse))
            }
        }
        println("posts: \(blogs)")
    }
    
    
    
    
}