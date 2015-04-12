//
//  ConnectionManager.swift
//  iCasting
//
//  Created by T. van Steenoven on 08-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

private struct _SessionManager {
    static let sharedInstance : SessionManager = SessionManager()
}

class SessionManager: NSObject, NSURLSessionTaskDelegate {
    
    /* Singleton class */
    class func sharedInstance() -> SessionManager {
        return _SessionManager.sharedInstance
    }
    
    var delegate : AnyObject?
    
    /* The request method gets the shared session object on which it creates a task.
    * If this methods gets invoked multiple times, it adds more tasks to the session, the tasks
    * will be handled by operation queues on the background, we don't really need to care about it.
    * We should be care about that interface elements will be executed on the main queue.
    */
    func request(request : NSURLRequest, callbackClosure: RequestClosure) {

        let session = NSURLSession.sharedSession()
        let task:NSURLSessionDataTask = session.dataTaskWithRequest(request) {

            (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
            
            var result: AnyObject = JSONParser.JSONParse(data)
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                callbackClosure(data: result)
            }
            
        }
        
        task.resume()
    }
    
    /* DELEGATE METHODS */
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        
    }
    
    
    
    
    
    
}