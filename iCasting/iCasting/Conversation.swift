//
//  Negotiation.swift
//  iCasting
//
//  Created by Tim van Steenoven on 06/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

typealias JSONResponeType = (request: NSURLRequest, response: NSURLResponse?, json:AnyObject?, error:NSError?)->()
typealias SocketMessageCommunicationCallBack = (error: ICError?)->()

protocol SocketMessageCommunicationProtocol {
    
    func sendMessage(message: String, callBack: SocketMessageCommunicationCallBack)
    func acceptOffer(callBack: SocketMessageCommunicationCallBack)
    func rejectOffer(callBack: SocketMessageCommunicationCallBack)
}

struct ConversationToken : Printable {
    
    let token: String
    let client: String
    let url: String
    var description: String {
        return "token: \(token) client: \(client) url: \(url)"
    }
}


class Conversation: NSObject {
    
    let matchID: String
    let messageList: MessageListExtractor = MessageListExtractor()
    let messageFactory: MessageFactory = MessageFactory()
    var socketCommunicationHandler: SocketCommunicationHandler?
    
    var messages: [Message] {
        return messageList.list
    }
    
    private var conversationToken: ConversationToken?

    init(matchID:String) {
        self.matchID = matchID
    }
}





// The extension adds responsibilities for communicating with a socket library, the list below specifies what the extension does:
// it creates the socket with the conversation token
// It creates handlers for the socket to receive feedback if specific things are happening
// It handles the feedback
// It creates messages

extension Conversation : SocketCommunicationHandlerDelegate {
    
    
    private func createSocketCommunicationHandler() {
        
        self.socketCommunicationHandler = SocketCommunicationHandler(conversationToken: self.conversationToken!.token)
        self.socketCommunicationHandler?.delegate = self
    }
    
    
    // MARK: Socket communication handler delegate
    
    func handlersForSocketListeners() -> SocketHandlers {
        
        var handlers: SocketHandlers = SocketHandlers()
        
        handlers.connected = { data in
            
            println("--- Conversation: CONNECTED")
            
        }
        
        handlers.authenticated = { data in
            
            println("--- Conversation: AUTHENTICATED")
        }
        
        handlers.recievedMessage = { data in
            
            println("--- Conversation: RECIEVED MESSAGE")
            
            if let d = data {
                
                let body: String = d[0] as! String
                let userID: String = d[1] as! String
                let messageID: String = d[1] as! String
                
                // TODO: Check first if the owner is client
                var message: Message = self.messageFactory.createIncommingMessage(body: body, userID: userID, messageID: messageID)
                self.messageList.addMessage(message)
            }
        }
        // user join
        // user left
        return handlers
    }
    
    
    func sendMessage(message: String, callBack: SocketMessageCommunicationCallBack) {
        
        self.socketCommunicationHandler?.sendMessage(message, acknowledged: { () -> () in

            //return //String error	String message_id
            
        })
        
    }
    
    func acceptOffer(message: Message, callBack: SocketMessageCommunicationCallBack) {
        
        self.socketCommunicationHandler?.acceptOffer(message.id, acknowledged: { () -> () in
            
            //return String error, String accepted, Object by who (wel of niet)
            
        })
    }
    
    func rejectOffer(message: Message, callBack: SocketMessageCommunicationCallBack) {
        
        self.socketCommunicationHandler?.rejectOffer(message.id, acknowledged: { () -> () in
            
            //return String error, String accepted, Object by who (wel of niet)
            
        })
        
    }
    
}





extension Conversation : ModelRequest {
    
    func get(callBack: RequestClosure) {
        
        // This is a two step request, first get the conversation, and for instant sending and receiving messages, we need a conversation token
        
        let url: String = APIMatch.MatchConversation(self.matchID).value
        let access_token: AnyObject = Auth.auth.access_token as! AnyObject
        let params: [String : AnyObject] = ["access_token":access_token]
        
        request(Method.GET, url, parameters: params, encoding: ParameterEncoding.URL).responseJSON() { (request, response, json, error) -> Void in
                
            // Network or general errors?
            if let errors = ICError(error: error).getErrors() {
                callBack(failure: errors)
            }
            
            // No network errors, extract json
            if let _json: AnyObject = json {
                
                let messagesJSON = JSON(_json)
                
                // API Errors?
                if let errors = ICError(json: messagesJSON).getErrors() {
                    println(error)
                    callBack(failure: errors)
                    return
                }
                
                
                // There are no errors, perform the next request
                self.performRequestConversationToken(messagesJSON, callBack: callBack)

            }
        }
    }
    
    
    private func performRequestConversationToken(messagesJSON: JSON, callBack: RequestClosure) {

        // Request the conversation token
        self.requestConversationToken { (request, response, json, error) -> () in
            
            // Network or general errors?
            if let errors = ICError(error: error).getErrors() {
                callBack(failure: errors)
            }
            
            // No network errors, extract json
            if let _json: AnyObject = json {
                
                let tokenJSON = JSON(_json)
                
                // API Errors?
                if let errors = ICError(json: tokenJSON).getErrors() {
                    println(errors)
                    callBack(failure: errors)
                    return
                }
                
                
                // There are no errors, get everything to work
                self.setToken(tokenJSON)
                self.messageList.buildList(fromJSON: messagesJSON)
                
                // First, create a socket service, it wil set the delegate as well.
                self.createSocketCommunicationHandler()
                
                // Then let the controller know the first get request is ready, so it can prepare the view and observers.
                callBack(failure: nil)
                
                // After that, add the listeners, this method will call the delegate for the handlers
                self.socketCommunicationHandler?.addListeners()
                
                // If everything is ready, start the socket
                self.socketCommunicationHandler?.start()
                
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

