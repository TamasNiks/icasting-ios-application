//
//  JSONParser.swift
//  iCasting
//
//  Created by T. van Steenoven on 09-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

class JSONParser {

    
    class func mockJSONParse(jsonString: String) -> AnyObject? {
        
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            return JSONParser.Parse(data)
        }
        
        return nil
    }
    
    
    class func Parse(data: NSData) -> AnyObject {
        
        if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
         
            //println(string)
            
            if (string as NSString).substringToIndex(1) == "[" {
                println("JSONParser: Will invoke array")
                return JSONParser.JSONParseArray(data)
            }
            else if (string as NSString).substringToIndex(1) == "{" {
                println("JSONParser: Will invoke dictionary")
                return JSONParseDictionary(data)
            } else {
                println("JSONParser: Won't parse anything")
            }
        }
        
        return []
    }
    
    class func JSONParseArray(data: NSData) -> [AnyObject] {
    
        if let array = NSJSONSerialization.JSONObjectWithData(
            data,
            options: NSJSONReadingOptions(0),
            error: nil)  as? [AnyObject]
        {
            return array
        }

        return [AnyObject]()
    }
    
    class func JSONParseDictionary(data: NSData) -> [String:AnyObject] {
        
        if let dictionary = NSJSONSerialization.JSONObjectWithData(
            data,
            options: NSJSONReadingOptions(0),
            error: nil)  as? [String:AnyObject]
        {
            return dictionary
        }

        return [String:AnyObject]()
    }
    
}
