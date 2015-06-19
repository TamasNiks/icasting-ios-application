// Playground - noun: a place where people can play

import UIKit








//var blabla = (1 == 1)



/*


let str1 = "[ {\"name\": \"John\", \"age\": 21}, {\"name\": \"Bob\", \"age\": 35} ]"
var data: NSData = str1.dataUsingEncoding(NSUTF8StringEncoding)!
var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)




let dateFormatter = NSDateFormatter()
dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'+'ss':'ss"

//2015-05-06T00:00:00+00:00
//var usLocale: NSLocale = NSLocale(localeIdentifier: "en_US")
//var gbLocale: NSLocale = NSLocale(localeIdentifier: "en_GB")

//var dateComponents: String =
if let  date: NSDate = dateFormatter.dateFromString("2015-05-06T00:00:00+00:00") {

    let visibleFormatter = NSDateFormatter()
    visibleFormatter.timeStyle = NSDateFormatterStyle.NoStyle
    visibleFormatter.dateStyle = NSDateFormatterStyle.LongStyle
    var str: String = visibleFormatter.stringFromDate(date)

}



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

var l: String = "tim,tim"
var range = l.rangeOfString(",")
var index = range?.startIndex
index = index?.successor()
l.substringFromIndex(index!)

*/
