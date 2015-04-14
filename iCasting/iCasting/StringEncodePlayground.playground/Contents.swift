//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


var sEndcoding : String = "=Boyd.reho$rst+talent@icasting.com"




var mcs : NSMutableCharacterSet = NSMutableCharacterSet.alphanumericCharacterSet()
mcs.addCharactersInString(".")
var test : String = sEndcoding.stringByAddingPercentEncodingWithAllowedCharacters(mcs)!
