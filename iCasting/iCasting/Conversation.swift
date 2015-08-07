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



protocol ConversationErrorDelegate: class {
    func receivedErrorForConversation(error: ICErrorInfo)
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
    let messageList: MessageList = MessageList()
    var socketCommunicator: SocketCommunicator?
    weak var delegate: ConversationErrorDelegate?
    
    dynamic var incommingUser: Bool = false // Indicates whether the chat partner of the client is available
    dynamic var authenticated: Bool = false // Indicates whether the client user has been authenticated by the socket server
    
    var messages: [Message] {
        return messageList.list
    }
    
    internal var conversationToken: ConversationToken?

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