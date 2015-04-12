// Playground - noun: a place where people can play

import Foundation
import XCPlayground

func httpGet(request: NSURLRequest!, callback: (String, String?) -> Void) {

    var session = NSURLSession.sharedSession()
    var task = session.dataTaskWithRequest(request){
    
        (data, response, error) -> Void in
        if error != nil {
            callback("", error.localizedDescription)
        } else {
            var result = NSString(data: data, encoding:
                NSASCIIStringEncoding)!
            callback(result, nil)
        }
    }
    
    task.resume()
}

var request = NSMutableURLRequest(URL: NSURL(string: "http://www.google.com")!)

httpGet(request) {
    
    (data, error) -> Void in
    if error != nil {
        println(error)
    } else {
        println(data)
    }
    
}

XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)
