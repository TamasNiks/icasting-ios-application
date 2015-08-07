//
//  SocketCommunicationHandlerDelegate.swift
//  iCasting
//
//  Created by Tim van Steenoven on 04/08/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// The extension adds responsibilities for listening to the socket communicator for events and the handling of these events:
// It creates the socket with the conversation token and sets the delegate.
// It adds handlers for the socket to receive feedback if specific things are happening.
// It handles actions according to feedback from the socket communicator, if an error happens, it will call the errorHandler.



extension Conversation : SocketCommunicatorHandlerDelegate {
    
    internal func createSocketCommunicationHandler() {
        
        self.socketCommunicator = SocketCommunicator(conversationToken: self.conversationToken!.token)
        self.socketCommunicator?.delegate = self
    }
    
    // MARK: Socket communication handler delegate
    
    func handlersDictionaryForSocketListeners() -> SocketHandlers {
        
        var socketHandlers = SocketHandlers()
        let factory = SocketMessageFactory()
        
        // Helper index vars to points the location of a elements in the socket data array, if it will change in the future, just change it here
        let messageIDIndex = 3
        let byWhoIndex = 1
        
        socketHandlers.errorHandler = { error in
            self.delegate?.receivedErrorForConversation(error)
        }
        
        socketHandlers.addHandler(On.Authenticated) { data in
            self.authenticated = true
        }
        
        socketHandlers.addHandler(On.UserJoin) { data in
            self.decideUserPresent(data, present: true)
        }
        
        socketHandlers.addHandler(On.UserLeft) { data in
            self.decideUserPresent(data, present: false)
        }
        
        socketHandlers.addHandler(On.Message) { data in
            let message: Message = factory.createNormalMessage(data)
            self.messageList.addItem(message)
        }
        
        socketHandlers.addHandler(On.Offer) { data in
            let message: Message = factory.createOfferMessage(data)
            self.messageList.addItem(message)
        }
        
        socketHandlers.addHandler(On.ContractOffer) { data in
            let message: Message = factory.createOfferContractMessage(data)
            self.messageList.addItem(message)
        }
        
        socketHandlers.addHandler(On.AcceptOffer) { data in
            let messageID = data[messageIDIndex] as? String
            if let message: Message = self.messageList.itemByID(messageID!) {
                self.setOfferAcceptTalent(forMessage: message, to: true)
            }
        }
        
        socketHandlers.addHandler(On.RejectOffer) { data in
            let messageID = data[messageIDIndex] as? String
            if let message: Message = self.messageList.itemByID(messageID!) {
                self.setOfferAcceptTalent(forMessage: message, to: false)
            }
        }
        
        socketHandlers.addHandler(On.AccceptContractOffer) { data in
            let messageID = data[messageIDIndex] as? String
            if let message: Message = self.messageList.itemByID(messageID!) {
                if let byWho = data[byWhoIndex] as? [String:AnyObject] {
                    self.setNewMessageStatusForTalentClient(forMessage: message, byWho: byWho, mustNotify: true)
                }
            }
        }
        
        socketHandlers.addHandler(On.RejectContractOffer) { data in
            let messageID = data[messageIDIndex] as? String
            if let message: Message = self.messageList.itemByID(messageID!) {
                if let byWho = data[byWhoIndex] as? [String:AnyObject] {
                    self.setNewMessageStatusForTalentClient(forMessage: message, byWho: byWho, mustNotify: true)
                }
            }
        }
        
        socketHandlers.addHandler(On.RenegotiationRequest) { data in
            let message: Message = factory.createRenegotiationRequestMessage(data)
            self.messageList.addItem(message)
        }
        
        socketHandlers.addHandler(On.AcceptRenegotiationRequest) { data in
            let messageID: String? = data[messageIDIndex] as? String
            if let message: Message = self.messageList.itemByID(messageID!) {
                self.setNegotiationRequestAcceptTalent(forMessage: message, to: true)
            }
        }
        
        socketHandlers.addHandler(On.RejectRenegotiationRequest) { data in
            let messageID: String? = data[messageIDIndex] as? String
            if let message: Message = self.messageList.itemByID(messageID!) {
                self.setNegotiationRequestAcceptTalent(forMessage: message, to: false)
            }
        }
        
        socketHandlers.addHandler(On.CompletedConfirmation) { data in
            let message: Message = factory.createReportCompletedRequestMessage(data)
            self.messageList.addItem(message)
        }
        
        socketHandlers.addHandler(On.MarkCompleted) { data in
            let messageID = data[messageIDIndex] as? String
            if let message: Message = self.messageList.itemByID(messageID!) {
                if let byWho = data[byWhoIndex] as? [String:AnyObject] {
                    self.setNewMessageStatusForTalentClient(forMessage: message, byWho: byWho, mustNotify: true)
                }
                
            }
        }
        
        socketHandlers.addHandler(On.MarkNotCompleted) { data in
            let messageID = data[messageIDIndex] as? String
            if let message: Message = self.messageList.itemByID(messageID!) {
                if let byWho = data[byWhoIndex] as? [String:AnyObject] {
                    self.setNewMessageStatusForTalentClient(forMessage: message, byWho: byWho, mustNotify: true)
                }
            }
        }
        
        return socketHandlers
    }
    
    
    // Helper functions to handle the change in model
    
    private func decideUserPresent(data: NSArray, present: Bool) {
        let userID = data[0] as! String
        let role = MessageRole.getRole(userID)
        if role == MessageRole.Incomming {
            self.incommingUser = present
        }
    }
    
    private func setOfferAcceptTalent(forMessage message: Message, to bool: Bool ) {
        
        message.offer?.acceptTalent = bool
        self.notifyObserver(forMessage: message)
    }
    
    
    internal func setNewMessageStatusForTalentClient(forMessage message: Message, byWho: [String:AnyObject], mustNotify notify: Bool) {
        
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


