//
//  TalentMatch.swift
//  iCasting
//
//  Created by Tim van Steenoven on 15/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//
// A specialized model class for talents

import Foundation

// TODO: JSON data is updated on the server, do something with it.

class TalentMatchCard: MatchCard {
    
    func accept(callBack:RequestClosure) {
        
        if let ID = super.getID(FieldID.MatchCardID) {
            
            var url: String = APIMatch.MatchAcceptTalent(ID).value
            var access_token: AnyObject = Auth.auth.access_token as! AnyObject
            var params: [String : AnyObject] = ["access_token":access_token]
            
            // TEST: comment the request code below if you do the accept test
            //testAccept(callBack)
            
            request(.POST, url, parameters: params).responseJSON() { (request, response, json, error) in
                
                if (error != nil) {
                    NSLog("Error: \(error)")
                    println(request)
                    println(response)
                }
                
                if let json: AnyObject = json {
                    
                    let parsedJSON = JSON(json)
                    var errorInfo: ICErrorInfo? = ICError(json: parsedJSON).getErrors()
                    
                    // Before doing a success callback to the controller, first delegate
                    if errorInfo == nil {
                        self.setStatus(FilterStatusFields.TalentAccepted)
                        self.delegate?.didAcceptMatch()
                    }
                    
                    callBack(failure: errorInfo)
                }
                
                println(response)
                println(json)
            }
        }
    }
    
    func reject(callBack:RequestClosure) {
        
        if let ID = super.getID(FieldID.MatchCardID) {
            
            var url: String = APIMatch.MatchRejectTalent(ID).value
            var access_token: AnyObject = Auth.auth.access_token as! AnyObject
            var params: [String : AnyObject] = ["access_token":access_token]
            
            // TEST: comment the request code below if you do the reject
            //testReject(callBack)
            
            
            request(.POST, url, parameters: params).responseJSON() { (request, response, json, error) in
                
                if (error != nil) {
                    NSLog("Error: \(error)")
                    println(request)
                    println(response)
                }
                
                if let json: AnyObject = json {
                    
                    let parsedJSON = JSON(json)
                    var errorInfo: ICErrorInfo? = ICError(json: parsedJSON).getErrors()
                    
                    // Before do a success callback to the controller, first delegate
                    if errorInfo == nil {
                        self.delegate?.didRejectMatch()
                    }
                    
                    callBack(failure: errorInfo)
                }
                
                println(response)
                println(json)
            }

        }
    }
    
    // Test methods
    
    func testAccept(callBack: RequestClosure) {
        self.setStatus(FilterStatusFields.TalentAccepted)
        delegate?.didAcceptMatch()
        callBack(failure: nil)
    }
    
    func testReject(callBack: RequestClosure) {
        delegate?.didRejectMatch()
        callBack(failure: nil)
    }
    
    func testError(callBack: RequestClosure) {
        var errorInfo: ICErrorInfo? = ICError(json: JSON("test")).getErrors()
        callBack(failure: errorInfo)
    }
}