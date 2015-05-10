//
//  JSONParser.swift
//  iCasting
//
//  Created by T. van Steenoven on 09-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

class JSONParser {
    
    class func Parse(data: NSData) -> AnyObject {
        
        if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
         
            if string.length > 0 {

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


extension JSONParser {
    
    class func Parse2(data: NSData) -> AnyObject? {
        
        var error: NSError?
        if let object: AnyObject = NSJSONSerialization.JSONObjectWithData(
            data,
            options: NSJSONReadingOptions(0),
            error: &error)
        {
            
            // The parser only returns arrays or dictionarys
            if object is NSArray {
                
                return object as! NSArray
                
            } else if object is NSDictionary {
                
                return object as! NSDictionary
                
            } else {
                
                return nil
            }
        }
        
        return nil
    }
}

extension JSONParser {
    
    class func mockJSONParse(jsonString: String) -> AnyObject? {
        
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            return JSONParser.Parse2(data)
        }
        
        return nil
    }
    
}

extension JSONParser {
    
    typealias CustomDictionaryType = NSDictionary
    
    func parseForTableView(source: NSDictionary, route:[String]) -> CustomDictionaryType {
        
        var toLook: NSDictionary = source
        for r: String in route {
            toLook = toLook.objectForKey(r) as! NSDictionary
        }
        var final: CustomDictionaryType = recusiveParser(toLook, toArray:false)
        //println(final)
        return final
    }
    
    private func recusiveParser(dict: CustomDictionaryType, toArray: Bool = true) -> CustomDictionaryType {
        
        var sub: NSMutableDictionary = NSMutableDictionary()
        
        // Loop through the data set
        
        for (i, val) in enumerate(dict) {
            
            var key: String = val.key as! String
            
            // Check the types of the value
            
            if val.value is CustomDictionaryType {
                
                var d = val.value as! CustomDictionaryType
                var insert: CustomDictionaryType = self.recusiveParser(d, toArray: toArray)
                
                // if toArray is true, every key value pairs will be inserted into an array element to improve looping
                
                if toArray == true {
                    var arr: [CustomDictionaryType] = [CustomDictionaryType]()
                    for (i, val) in enumerate(insert) {
                        var d: CustomDictionaryType = CustomDictionaryType(object: val.value, forKey: val.key as! String)
                        arr.append(d)
                    }
                    //return CustomDictionaryType(object: arr, forKey: "test")

                    sub.setValue(arr, forKey: key)
                } else {
                    sub.setValue(insert, forKey: key)
                }
                
            }
            else if val.value is NSArray {
                sub.setValue(val.value as! NSArray, forKey: key)
            }
            else {
                // Ignore false Boolean values
                if val.value is Bool {
                    if val.value as! Bool == false {
                        sub.setValue("false", forKey: key)
                    } else {
                        sub.setValue("true", forKey: key)
                    }
                    
                } else {
                    sub.setValue(val.value, forKey: key)
                }
                
            }
        }
        
        return sub
    }
    
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



