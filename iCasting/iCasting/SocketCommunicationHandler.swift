//
//  SocketCommunicationHandler.swift
//  iCasting
//
//  Created by Tim van Steenoven on 09/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// The socket configuration to use in the class

struct SocketConfig {
    static var server: String       = "https://ws-demo.icasting.net"
    static var namespace: String    = "chat"
    static var log: Bool            = true
    static var forcePolling: Bool   = true
    static var forceWebsockets:Bool = false
}


// to recieve feedback from a listener, add a handler here, after that, we can call it from a specific socket listener

struct SocketHandlers {
    
    typealias SocketHandlerType = (data: NSArray?)->()
    
    var recievedMessage     : SocketHandlerType = { data in }
    var authenticated       : SocketHandlerType = { data in }
    var connected           : SocketHandlerType = { data in }
    var userjoined          : SocketHandlerType = { data in }
    var userleft            : SocketHandlerType = { data in }
}


enum Emit: String {
    case Authenticate   = "authenticate"
    case Message        = "message"
    case OfferAccept    = "accept offer"
    case OfferReject    = "reject offer"
}

protocol SocketCommunicationHandlerDelegate {
    
    func handlersForSocketListeners() -> SocketHandlers
    
}




class SocketCommunicationHandler {
    
    // Create the socket and install it through the SocketConfig struct
    
    let socket = SocketIOClient(socketURL: SocketConfig.server, opts: [
        "nsp"               :SocketConfig.namespace,
        "log"               :SocketConfig.log,
        "forcePolling"      :SocketConfig.forcePolling,
        "forceWebsockets"   :SocketConfig.forceWebsockets])
    
    // Init vars
    
    var conversationToken: String // "cc0f111e9679f0c987cd757b7886f3b34c37b5c4551d58a226042f74fb7455335550719e98c8d69c856e08826aa67555"
    var delegate: SocketCommunicationHandlerDelegate?
    
    init(conversationToken: String) {
        self.conversationToken = conversationToken
    }
    
    
    func removeListeners() {
        
        self.socket.off("connect")
        
    }
    
    func addListeners() {
        
        let handlers: SocketHandlers = self.delegate?.handlersForSocketListeners() ?? SocketHandlers()
        
        self.socket.on("connect") {[conversationToken] data, ack in
            
            handlers.connected(data: data)
            
            self.socket.emitWithAck(Emit.Authenticate.rawValue, conversationToken)(timeout:0) { data in

                println("SocketCommunicationHandler: authenticated with ack")
            }
        }
        
        self.socket.on("authenticated") { data, ack in
            
            handlers.authenticated(data: data)
            
        }
        
        self.socket.on("message") { data, ack in

            handlers.recievedMessage(data: data)
        }
        
        
        self.socket.on("user join") { data, ack in
            
            if let user_id = data?[0] as? String {
                println(user_id)
            }
            
            ack?("User has been joined", "test")
        }
        
        
        self.socket.on("user left") { data, ack in
            

        }
        
        
        self.socket.on("accept offer") { data, ack in
            

        }
        
        self.socket.on("reject offer") { data, ack in
            

        }

        println("Will initialize socket")
        
        socket.on("connect") {data, ack in
            println("socket connected")
            
        }
        
        socket.onAny {println("Got event: \($0.event), with items: \($0)")}
        
    }
    
    
    func start() {
        
        self.socket.connect()
    }
    

    func sendMessage(message: String, acknowledged: () -> ()) {
        
        self.socket.emitWithAck(Emit.Message.rawValue, message)(timeout: 0, callback: { (data) -> Void in
            
            
            
        })
        
        //self.socket.emit(Emit.Message.rawValue, message)
    }
    
    
    func acceptOffer(messageID:String, acknowledged: () -> ()) {
     
        self.socket.emitWithAck(Emit.OfferAccept.rawValue, messageID)(timeout: 0) { data in
            
            println("*** ack ***")
            println(data)
            
        }
    }
    
    
    func rejectOffer(messageID: String, acknowledged: () -> ()) {
        
        self.socket.emitWithAck(Emit.OfferReject.rawValue, messageID)(timeout: 0) { data in
            
            println("*** ack ***")
            println(data)
            
        }
        
    }
    
    
    
}