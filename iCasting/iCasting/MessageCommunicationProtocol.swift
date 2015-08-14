//
//  MessageCommunicationProtocol.swift
//  iCasting
//
//  Created by Tim van Steenoven on 04/08/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

protocol MessageCommunicationProtocol {
    
    func sendMessage(text: String, callBack: MessageCommunicationCallBack)
    func acceptOffer(message: Message, callBack: MessageCommunicationCallBack)
    func rejectOffer(message: Message, callBack: MessageCommunicationCallBack)
    func acceptContract(message: Message, callBack: MessageCommunicationCallBack)
    func rejectContract(message: Message, callBack: MessageCommunicationCallBack)
    func acceptRenegotiationRequest(message: Message, callBack: MessageCommunicationCallBack)
    func rejectRenegotiationRequest(message: Message, callBack: MessageCommunicationCallBack)
    func acceptJobCompleted(message: Message, callBack: MessageCommunicationCallBack)
    func rejectJobCompleted(message: Message, callBack: MessageCommunicationCallBack)
}




extension Conversation : MessageCommunicationProtocol {
    
    
    func sendMessage(text: String, callBack: MessageCommunicationCallBack) {
        
        let m: Message = Message(id: String(), owner: Auth.passport!.userID, role: MessageRole.Outgoing, type: TextType.Text)
        m.body = text
        
        self.socketCommunicator?.sendMessage(m.body!, acknowledged: { (data) -> () in
            
            if let d = data {
                if let error: ICErrorInfo = ICError(string: d[0] as? String).errorInfo {
                    callBack(error: error)
                    return
                }
                self.messageList.addItem(m)
                callBack(error: nil)
            }
            callBack(error: ICError(string: "Could not send message").errorInfo)
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
                let error: ICErrorInfo? = self.validateAndSetMessageStatus(d, withMessageToUpdate: message)
                callBack(error: error)
            }
        })
    }
    
    func rejectContract(message: Message, callBack: MessageCommunicationCallBack) {
        
        self.socketCommunicator?.rejectContract(message.id, acknowledged: { (data) -> () in
            
            if let d = data {
                let error: ICErrorInfo? = self.validateAndSetMessageStatus(d, withMessageToUpdate: message)
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
    
    func acceptJobCompleted(message: Message, callBack: MessageCommunicationCallBack) {
        
        self.socketCommunicator?.acceptJobCompleted(message.id, acknowledged: { (data) -> () in
            
            if let d = data {
                let error: ICErrorInfo? = self.validateAndSetMessageStatus(d, withMessageToUpdate: message)
                callBack(error: error)
            }
        })
    }
    
    func rejectJobCompleted(message: Message, callBack: MessageCommunicationCallBack) {
        
        self.socketCommunicator?.rejectJobCompleted(message.id, acknowledged: { (data) -> () in
            
            if let d = data {
                let error: ICErrorInfo? = self.validateAndSetMessageStatus(d, withMessageToUpdate: message)
                callBack(error: error)
            }
        })
        
    }
    
    // Helper functions
    
    private func decideOfferAcceptRejection(data: NSArray, withMessageToUpdate message: Message) -> ICErrorInfo? {
        
        let error: ICErrorInfo? = ICError(string: data[0] as? String).errorInfo
        if error == nil {
            var accepted: Bool?     = (data[1] as! Int).toBool()
            var byWho: [String:Int] = (data[2] as! [String:Int])
            var hasAcceptTalent = (byWho["acceptTalent"] ?? 0).toBool()
            message.offer!.acceptTalent = hasAcceptTalent
        }
        return error
    }
    
    private func validateAndSetMessageStatus(data: NSArray, withMessageToUpdate message: Message) -> ICErrorInfo? {
        
        let error: ICErrorInfo? = ICError(string: data[0] as? String).errorInfo
        if error == nil {
            let byWho = data[2] as! [String:AnyObject]
            self.setNewMessageStatusForTalentClient(forMessage: message, byWho: byWho, mustNotify: false)
            
            
        }
        return error
    }
}
