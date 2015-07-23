//
//  Negotiation.swift
//  iCasting
//
//  Created by Tim van Steenoven on 06/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

typealias JSONResponeType = (request: NSURLRequest, response: NSURLResponse?, json:AnyObject?, error:NSError?)->()
typealias MessageCommunicationCallBack = (error: ICErrorInfo?)->()




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
    let messageList: MessageList = MessageList()
    var socketCommunicator: SocketCommunicator?

    
    dynamic var incommingUser: Bool = false // Indicates whether the chat partner of the client is available
    dynamic var authenticated: Bool = false // Indicates whether the client user has been authenticated by the socket server
    
    var messages: [Message] {
        return messageList.list
    }
    
    private var conversationToken: ConversationToken?

    init(matchID:String) {
        self.matchID = matchID
    }
    
    func leaveConversation() {
        self.socketCommunicator?.stop()
    }
    
    func enterConversation() {
        self.socketCommunicator?.start()
    }
    
}




// The extension adds responsibilities for communicating with a socket library, the list below specifies what the extension does:
// it creates the socket with the conversation token and sets the delegate
// It creates handlers for the socket to receive feedback if specific things are happening, it is similar to the command pattern
// It handles actions according to feedback

extension Conversation : SocketCommunicationHandlerDelegate {
    
    
    private func createSocketCommunicationHandler() {
        
        self.socketCommunicator = SocketCommunicator(conversationToken: self.conversationToken!.token)
        self.socketCommunicator?.delegate = self
    }
    

    // MARK: Socket communication handler delegate
    
    func handlersForSocketListeners() -> SocketHandlers {
        
        var handlers: SocketHandlers = SocketHandlers()
        
        handlers.authenticated = { data in
            
            println("--- Conversation: AUTHENTICATED")
            
            // This should be the moment that the user can start typing and receiving messages
            self.authenticated = true
        }
        
        handlers.userjoined = { data in
            
            if let d = data {
                self.decideUserPresent(d, present: true)
            }
        }
        
        handlers.userleft = { data in
            
            if let d = data {
                self.decideUserPresent(d, present: false)
            }
        }
        
        handlers.receivedMessage = { data in
            
            if let d = data {
                let factory = SocketMessageFactory()
                let message: Message = factory.createNormalMessage(d)
                self.messageList.addItem(message)
            }
        }
        
        handlers.receivedOffer = { data in
         
            if let d = data {
                let factory = SocketMessageFactory()
                let message: Message = factory.createOfferMessage(d)
                self.messageList.addItem(message)
            }
        }

        handlers.receivedContractOffer = { data in
         
            //"accept contract offer"	String new status	Object by who	String user_id	ObjectId van message
            //Event name	Optionele nieuwe status	Wie wel/ niet?	ObjectId van user

            if let d = data {
                let factory = SocketMessageFactory()
                let message: Message = factory.createOfferContractMessage(d)
                self.messageList.addItem(message)
            }
        }
        
        handlers.offerAccepted = { data in

            if let d = data {
                let messageID = d[3] as? String
                if let message: Message = self.messageList.itemByID(messageID!) {
                    self.setOfferAcceptTalent(forMessage: message, to: true)
                }
            }
        }
        
        handlers.offerRejected = { data in

            if let d = data {
                let messageID = d[3] as? String
                if let message: Message = self.messageList.itemByID(messageID!) {
                    self.setOfferAcceptTalent(forMessage: message, to: false)
                }
            }
        }
        
        handlers.contractOfferAccepted = { data in
            
            if let d = data {
                //Data: status (Int), byWho ([String:AnyObject]), userID (String), messageID (String)
                let messageID = d[3] as? String
                if let message: Message = self.messageList.itemByID(messageID!) {
                    let byWho = d[1] as! [String:AnyObject]
                    self.setContractOfferAcceptClientOrTalent(forMessage: message, byWho: byWho, mustNotify: true)
                }
            }
        }
        
        handlers.contractOfferRejected = { data in
         
            if let d = data {
                //Data: status (Int), byWho ([String:AnyObject]), userID (String), messageID (String)
                let messageID = d[3] as? String
                if let message: Message = self.messageList.itemByID(messageID!) {
                    let byWho = d[1] as! [String:AnyObject]
                    self.setContractOfferAcceptClientOrTalent(forMessage: message, byWho: byWho, mustNotify: true)
                }
            }
        }
        
        handlers.receivedRenegotiationRequest = { data in
         
            if let d = data {
                let factory = SocketMessageFactory()
                let message: Message = factory.createRenegotiationRequestMessage(d)
                self.messageList.addItem(message)
            }
        }
        
        handlers.renegotiationRequestAccepted = { data in

            if let d = data {
                let messageID: String?   = d[3] as? String
                if let message: Message = self.messageList.itemByID(messageID!) {
                    self.setNegotiationRequestAcceptTalent(forMessage: message, to: true)
                }
            }
        }
        
        handlers.renegotiationRequestRejected = { data in
            
            if let d = data {
                let messageID: String?   = d[3] as? String
                if let message: Message = self.messageList.itemByID(messageID!) {
                    self.setNegotiationRequestAcceptTalent(forMessage: message, to: false)
                }
            }
            
        }
        
        return handlers
    }
    
    
    // Helper functions to handle the change in model
    
    private func decideUserPresent(data: NSArray, present: Bool) {
        let userID = data[0] as! String
        let role = Role.getRole(userID)
        if role == Role.Incomming {
            self.incommingUser = present
        }
    }
    
    private func setOfferAcceptTalent(forMessage message: Message, to bool: Bool ) {
        
        message.offer?.acceptTalent = bool
        self.notifyObserver(forMessage: message)
    }
    
    private func setContractOfferAcceptClientOrTalent(forMessage message: Message, byWho: [String:AnyObject], mustNotify notify: Bool) {
        
        // Because the value can be a string "<null>" and an int 0,1
        func unwrap(object: AnyObject?) -> Bool? {
            if let o: AnyObject = object {
                if o is Int {
                    return (o as! Int).toBool()
                } else {
                    return nil
                }
            }
            return nil
        }
        
        let acceptClient: Bool? = unwrap(byWho["acceptClient"])
        let acceptTalent: Bool? = unwrap(byWho["acceptTalent"])
        let accepted: Bool?     = unwrap(byWho["accepted"])
        
//        println("acceptClient")
//        println(acceptClient)
//        println("acceptTalent")
//        println(acceptTalent)
//        println("accepted")
//        println(accepted)
        
        message.offer?.stateComponents = StateComponents(acceptClient: acceptClient, acceptTalent: acceptTalent, accepted: accepted)
        
        if notify { self.notifyObserver(forMessage: message) }
    }
    
    private func setNegotiationRequestAcceptTalent(forMessage message: Message, to bool: Bool ) {
        
        message.offer?.stateComponents = StateComponents(acceptClient: true, acceptTalent: bool, accepted: bool)
        self.notifyObserver(forMessage: message)
    }
    
    
    // A wrapper function to encapsulate the notification
    private func notifyObserver(forMessage message: Message) {
        
        // If the changeClosure has been set, call it
        if let changeClosure = message.notifyChange {
            
            // But first check if the item exist in the list for it to call
            if let index = self.messageList.indexForItem(message) {
                changeClosure(message: message, index: index)
            }
        }
    }
}




protocol MessageCommunicationProtocol {
    
    func sendMessage(text: String, callBack: MessageCommunicationCallBack)
    func acceptOffer(message: Message, callBack: MessageCommunicationCallBack)
    func rejectOffer(message: Message, callBack: MessageCommunicationCallBack)
    func acceptContract(message: Message, callBack: MessageCommunicationCallBack)
    func rejectContract(message: Message, callBack: MessageCommunicationCallBack)
    func acceptRenegotiationRequest(message: Message, callBack: MessageCommunicationCallBack)
    func rejectRenegotiationRequest(message: Message, callBack: MessageCommunicationCallBack)
}




extension Conversation: MessageCommunicationProtocol {
    

    func sendMessage(text: String, callBack: MessageCommunicationCallBack) {
     
        let m: Message = Message(id: String(), owner: Auth.passport!.user_id, role: Role.Outgoing, type: TextType.Text)
        m.body = text

        self.socketCommunicator?.sendMessage(m.body!, acknowledged: { (data) -> () in

            if let d = data {
                if let error: ICErrorInfo = ICError(string: d[0] as? String).getErrors() {
                    callBack(error: error)
                    return
                }
                self.messageList.addItem(m)
                callBack(error: nil)
            }
            callBack(error: ICError(string: "Could not send message").getErrors())
        })
    }
    
    func acceptOffer(message: Message, callBack: MessageCommunicationCallBack) {

        self.socketCommunicator?.acceptOffer(message.id, acknowledged: { (data) -> () in
            
            if let d = data {
                let error: ICErrorInfo? = self.decideOfferAcceptRejection(d, withMessageToUpdate: message)
                callBack(error: error)
            }
        })
    }
    
    func rejectOffer(message: Message, callBack: MessageCommunicationCallBack) {
        
        self.socketCommunicator?.rejectOffer(message.id, acknowledged: { (data) -> () in
            
            if let d = data {
                let error: ICErrorInfo? = self.decideOfferAcceptRejection(d, withMessageToUpdate: message)
                callBack(error: error)
            }
        })
    }
    
    func acceptContract(message: Message, callBack: MessageCommunicationCallBack) {
        
        self.socketCommunicator?.acceptContract(message.id, acknowledged: { (data) -> () in
            
            if let d = data {
                let error: ICErrorInfo? = self.decideContractAcceptRejection(d, withMessageToUpdate: message)
                callBack(error: error)
            }
        })
    }

    func rejectContract(message: Message, callBack: MessageCommunicationCallBack) {
        
        self.socketCommunicator?.rejectContract(message.id, acknowledged: { (data) -> () in

            if let d = data {
                let error: ICErrorInfo? = self.decideContractAcceptRejection(d, withMessageToUpdate: message)
                callBack(error: error)
            }
        })
    }
    
    func acceptRenegotiationRequest(message: Message, callBack: MessageCommunicationCallBack) {
        
        self.socketCommunicator?.acceptRenegotiationRequest(message.id, acknowledged: { (data) -> () in
            
            if let d = data {
                let accepted = true
                message.offer?.stateComponents = StateComponents(acceptClient: true, acceptTalent: accepted, accepted: accepted)
                callBack(error: nil)
            }
        })
    }
    
    func rejectRenegotiationRequest(message: Message, callBack: MessageCommunicationCallBack) {
    
        self.socketCommunicator?.rejectRenegotiationRequest(message.id, acknowledged: { (data) -> () in
            
            if let d = data {
                let accepted = false
                message.offer?.stateComponents = StateComponents(acceptClient: true, acceptTalent: accepted, accepted: accepted)
                callBack(error: nil)
            }
        })
    }
    
    
    // Helper functions
    
    private func decideOfferAcceptRejection(data: NSArray, withMessageToUpdate message: Message) -> ICErrorInfo? {
    
        let error: ICErrorInfo? = ICError(string: data[0] as? String).getErrors()
        if error == nil {
            var accepted: Bool?     = (data[1] as! Int).toBool()
            var byWho: [String:Int] = (data[2] as! [String:Int])
            var hasAcceptTalent = (byWho["acceptTalent"] ?? 0).toBool()
            message.offer!.acceptTalent = hasAcceptTalent
        }
        return error
    }

    private func decideContractAcceptRejection(data: NSArray, withMessageToUpdate message: Message) -> ICErrorInfo? {
        
        let error: ICErrorInfo? = ICError(string: data[0] as? String).getErrors()
        if error == nil {
            let byWho = data[2] as! [String:AnyObject]
            self.setContractOfferAcceptClientOrTalent(forMessage: message, byWho: byWho, mustNotify: false)
        }
        return error
    }
}




extension Conversation : ModelRequest {
    
    func get(callBack: RequestClosure) {
        
        // This is a two step request, first get the conversation, and for instant sending and receiving messages, we need a conversation token
        request(Router.Match.MatchConversation(self.matchID)).responseJSON() { (request, response, json, error) -> Void in
                
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
                self.socketCommunicator?.addListeners()
                
                // If everything is ready, start the socket
                self.socketCommunicator?.start()
                
            }
        }
    }
    
    
    private func requestConversationToken(callBack: JSONResponeType) {
        
        request(Router.Match.MatchConversationToken(self.matchID))
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

