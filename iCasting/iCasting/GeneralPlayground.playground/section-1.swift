// Playground - noun: a place where people can play

import UIKit







var str = "Hello, playground"
let string = "[ {\"name\": \"John\", \"age\": 21}, {\"name\": \"Bob\", \"age\": 35} ]"


var sEndcoding : String = "bo@yd.reho1rst+talent@icasting.com"

var test : String = sEndcoding.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.decimalDigitCharacterSet())!

//sEndcoding  = sEndcoding.stringByAddingPercentEncodingWithAllowedCharacters(
//    NSCharacterSet.symbolCharacterSet())!

var lala = sEndcoding.stringByAddingPercentEscapesUsingEncoding(NSUnicodeStringEncoding)!

var data : NSData = lala.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!

var back : NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!


//newStr =

//NSString* newStr = [NSString stringWithUTF8String:[theData bytes]]



func evokeSomething(num:Int, callBack:((voor:String, achter:String))->()) {
    
    //callBack(name: "Tim")
    callBack((voor: "Tim", achter: "van Steenoven"))
}


var n :String = "lala"
evokeSomething(1) {
    
    (voor:String, achter:String) in
    
    n = voor
    
}
n


var params : [String:String] = ["key":"val", "key1":"val1"]



var resolved : NSString = "lala/lala/lala"

// Add the query string to the path

resolved = "\(resolved)?"
//var resolvedParams : String = String()
for (key, val) in params {
    resolved = "\(resolved)\(key)=\(val)&"
}
// Remove the last & char from the query string
resolved = resolved.substringToIndex(resolved.length-1)

