//
//  ConnectionManager.swift
//  iCasting
//
//  Created by T. van Steenoven on 08-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

//enum Result<A> {
//    case Error(NSError)
//    case Value(A)
//}

class SessionManager: NSObject, NSURLSessionTaskDelegate {
    
    /* Singleton class */
    static let sharedInstance : SessionManager = SessionManager()
    
    var delegate : AnyObject?
    
    /* The request method gets the shared session object on which it creates a task.
    * If this methods gets invoked multiple times, it adds more tasks to the session, the tasks
    * will be handled by operation queues on the background, we don't really need to care about it.
    * We should be care about that interface elements will be executed on the main queue.
    */
    func request(request : NSURLRequest, callbackClosure: ((success:AnyObject?, failure:NSError?)) -> ()) {

        var session = NSURLSession.sharedSession()
        
//        var config : NSURLSessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
//        config.HTTPAdditionalHeaders = ["Content-Type":"application/json; charset=UTF-8"]
//        session = NSURLSession(configuration: config)
        
        let task:NSURLSessionDataTask = session.dataTaskWithRequest(request) {

            (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
            
            println("HTTP TASK FINNISHED ")
            
            // Check if there is a response, if there is
            if let res = response {

                var res: NSHTTPURLResponse = response as! NSHTTPURLResponse
                var allHeaderFields: [NSObject : AnyObject] = res.allHeaderFields

                println("Status Code", res.statusCode)
                //println("Description: ")
                //println(res.description)
                
                // Check for a content type, if there is one, it will be json, invoke the json parser
                var resultObject: AnyObject?
                var contentType: String? = allHeaderFields["Content-Type"] as? String
                if let str = contentType {
                    resultObject = JSONParser.Parse(data)
                }
                // Because there is no content type, the server will return a data object, which needs to converted to a string
                else {
                    resultObject = data
                }
                
                // Go to the main queueu, where the interfaces exists
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    
                    callbackClosure((success:resultObject, failure:error))
                }
            }
        }
        
        task.resume()
    }
    
    /* DELEGATE METHODS */
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        println(error!.localizedDescription)
        println(error!.localizedFailureReason)
        println(error!.localizedRecoverySuggestion)
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        
    }
}
