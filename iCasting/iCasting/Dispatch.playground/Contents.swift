//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
dispatch_after(popTime, dispatch_get_main_queue(), {

})