//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


var obj: NSDictionary = NSDictionary(object: "second level", forKey: "first2")
var obj2: NSDictionary = NSDictionary(objects: ["rara", "biiiier"], forKeys: ["A","B"])

var keys: [AnyObject] = ["first", "second", "third", "forth"]
var objects: [AnyObject] = ["A", "B", obj, obj2]


var dict: NSDictionary = NSDictionary(objects: objects, forKeys: keys)


// Now I want to get the latest


// I need to

//var newDic: NSDictionary

var collector: NSMutableArray = NSMutableArray()

func getLatestObject(d: NSDictionary, inout c:NSMutableArray) -> NSDictionary? {
    
    var col: NSMutableArray = NSMutableArray()
    
    for (key, val) in d {
        if val is NSDictionary {
            col.addObject(val)
        }
    }
    for val in col {
        c.addObject(getLatestObject(val as! NSDictionary, &c)!)
    }
    return d
}


var final: NSDictionary = getLatestObject(dict, &collector)!

collector