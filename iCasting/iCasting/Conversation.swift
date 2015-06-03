//
//  Negotiation.swift
//  iCasting
//
//  Created by Tim van Steenoven on 06/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

typealias JSONResponeType = (request: NSURLRequest, response: NSURLResponse?, json:AnyObject?, error:NSError?)->()


struct ConversationToken : Printable {
    let token: String
    let client: String
    let url: String
    var description: String {
        return "token: \(token) client: \(client) url: \(url)"
    }
}


class Conversation {
    
    let matchID: String
    var messageManager: MessageManager = MessageManager()
    var messages: [Message] {
        return messageManager.messages
    }
    
    
    private var conversationToken: ConversationToken?

    init(matchID:String) {
        self.matchID = matchID
    }
    
}


extension Conversation : ModelRequest {
    
    func get(callBack: RequestClosure) {
        
        let url: String = APIMatch.MatchConversation(self.matchID).value
        let access_token: AnyObject = Auth.auth.access_token as! AnyObject
        let params: [String : AnyObject] = ["access_token":access_token]
        
        request(Method.GET, url, parameters: params, encoding: ParameterEncoding.URL)
            .responseJSON() { (request, response, json, error) -> Void in
                
                var errors = ICError(error: error).getErrors()
                if let messagesJSON: AnyObject = json {
                    
                    self.requestConversationToken { (request, response, json, error) -> () in
                        
                        var errors = ICError(error: error).getErrors()
                        //println(messagesJSON)
                        if let tokenJSON: AnyObject = json {
                            
                            if let error = ICError(json: JSON(messagesJSON)).getErrors() {
                                println(error)
                            }
                            
                            self.setToken(JSON(tokenJSON))
                            self.messageManager.setMessages(JSON(messagesJSON))
                            
                            //self.initializeSocket()
                            callBack(failure: errors)
                        }
                    }
                }
        }
        
    }

    
    private func requestConversationToken(callBack: JSONResponeType) {
        
        let url: String = APIMatch.MatchConversationToken(self.matchID).value
        let access_token: AnyObject = Auth.auth.access_token as! AnyObject
        let params: [String : AnyObject] = ["access_token":access_token]
        
        request(Method.GET, url, parameters: params, encoding: ParameterEncoding.URL)
            .responseJSON() { (request, response, json, error) -> Void in
                callBack(request: request, response: response, json: json, error: error)
        }
    }
    
    
    private func setToken(json: JSON) {
        
        // TEST: if necessary, test all the values at once before create an instant of conversation token
        let values = [
            json["token"].stringValue,
            json["client"].stringValue,
            json["url"].stringValue]
        conversationToken = ConversationToken(token: values[0], client: values[1], url: values[2])
    }
    
    
}

// Handles the sockets

/*extension Conversation {
    
    //let socket = SocketIOClient(socketURL: "https://ws-demo.icasting.net")

    private func initializeSocket() {
        
        println("Will initialize socket")
        
        socket.on("connect") {data, ack in
            println("socket connected")
        
        }
        
        socket.onAny {println("Got event: \($0.event), with items: \($0)")}

        socket.connect()
        
        socket.emit("authenticate", "ddb7abf83fbbf8a3ba30f20eeb042c83be536430551d58a226042f74fb745533554779c4fd5f86e446c58fc0865c4b55")
        
//        var items: [AnyObject] = ["ddb7abf83fbbf8a3ba30f20eeb042c83be536430551d58a226042f74fb745533554779c4fd5f86e446c58fc0865c4b55"]
//        socket.emitWithAck("authenticate", items)(timeout:1) { arr in
//            println(arr)
//        }
        
//        var params: [String:AnyObject] = ["authenticate": conversationToken!.token as AnyObject]
//        socket.connectWithParams(params)
        
        
        
        //println(conversationToken!.token)
        
        
        
//        if (socket.connected == true) {
//            
//            println("IS CONNECTED")
//            
//        }
        
    }

} */

