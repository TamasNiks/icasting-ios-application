//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

func isInvalidEmail(string: String) -> Bool {
    
    let pattern: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    let regularExpression: NSRegularExpression? = NSRegularExpression(
        pattern: pattern,
        options: NSRegularExpressionOptions(0),
        error: nil)
    
    var num: Int = 0
    if let regEx = regularExpression {
        num = regEx.numberOfMatchesInString(string, options: NSMatchingOptions(0), range: NSMakeRange(0, count(string)))
    }
    return num > 0 ? true : false
}

//var test : Bool = isInvalidEmail("ti+mvs.nl+@gmail.com")
