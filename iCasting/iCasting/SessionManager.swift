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

typealias ResultTuple = (success:AnyObject?, failure:NSError?)
typealias RequestClosure = (ResultTuple) -> ()

class SessionManager: NSObject, NSURLSessionTaskDelegate {
    
    /* Singleton class */
    static let sharedInstance : SessionManager = SessionManager()
    
    var delegate : AnyObject?
    
    /* The request method gets the shared session object on which it creates a task.
    * If this methods gets invoked multiple times, it adds more tasks to the session, the tasks
    * will be handled by operation queues on the background, we don't really need to care about it.
    * We should be care about that interface elements will be executed on the main queue.
    */
    func request(request : NSURLRequest, callbackClosure: RequestClosure) {

        var session = NSURLSession.sharedSession()
        
//        var config : NSURLSessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
//        config.HTTPAdditionalHeaders = ["Content-Type":"application/json; charset=UTF-8"]
//        session = NSURLSession(configuration: config)
        
        let task:NSURLSessionDataTask = session.dataTaskWithRequest(request) {

            (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
            
            var result: AnyObject = JSONParser.Parse(data)

            //var data: NSData = self.currentRequest.HTTPBody
            
            
            println("HTTP TASK FINNISHED ")
            println("Result: ")
            println(result)
            println("Description: ")
            println(response.description)
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                
                var err : NSError? = nil
                if let err = error {}
                callbackClosure((success:result, failure:err))
            }

        }
        
        task.resume()
    }
    
    /* DELEGATE METHODS */
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        
    }
    
    
    
    
    
    
}