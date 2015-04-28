// Playground - noun: a place where people can play

import Foundation

let string = "[ {\"name\": \"John\", \"age\": 21}, {\"name\": \"Bob\", \"age\": 35} ]"

//func JSONParseArray(jsonString: String) -> [AnyObject] {
    
//    if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
//        if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [AnyObject] {
//            
//            let name = array[0]["name"] as String
//
//        }
//    }

//}

//for elem: AnyObject in JSONParseArray(string) {
//    let name = elem["name"] as String
//    let age = elem["age"] as Int
//    println("Name: \(name), Age: \(age)")
//}

/*  Prints following

Name: John, Age: 21
Name: Bob, Age: 35

*/



//var str = "[ {\"name\": \"John\", \"age\": 21}, {\"name\": \"Bob\", \"age\": 35} ]"
//
//
//if let data = str.dataUsingEncoding(NSUTF8StringEncoding) {
//
//    if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as? [AnyObject] {
//        
//        
//        let name = array[0]["age"] as String
//        
//        //println()
//        
//        
//    }
//
//}
