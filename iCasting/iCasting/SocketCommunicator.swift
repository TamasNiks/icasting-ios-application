//
//  SocketCommunicator.swift
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

enum On: String {
    
    // Client events
    case Connect                    = "connect"
    case Error                      = "error"
    
    // API events
    case Authenticated              = "authenticated"

    case UserJoin                   = "user join"
    case UserLeft                   = "user left"

    case Message                    = "message"

    case Offer                      = "offer"
    case AcceptOffer                = "accept offer"
    case RejectOffer                = "reject offer"
    
    case ContractOffer              = "contract offer"
    case AccceptContractOffer       = "accept contract offer"
    case RejectContractOffer        = "reject contract offer"
    
    case RenegotiationRequest       = "renegotiation request"
    case AcceptRenegotiationRequest = "accept renegotiation request"
    case RejectRenegotiationRequest = "reject renegotiation request"
    
    case CompletedConfirmation      = "completed confirmation"
    case MarkCompleted              = "mark completed"
    case MarkNotCompleted           = "mark not completed"
}

enum Emit: String {
    case Authenticate           = "authenticate"
    case Message                = "message"
    case OfferAccept            = "accept offer"
    case OfferReject            = "reject offer"
    case ContractAccept         = "accept contract offer"
    case ContractReject         = "reject contract offer"
    case RenegotiationAccept    = "accept renegotiation request"
    case RenegotationReject     = "reject renegotiation request"
    case MarkCompleted          = "mark completed"
    case MarkNotCompleted       = "mark not completed"
}

// to recieve feedback from a listener, add a handler here, after that, we can call it from a specific socket listener

struct SocketHandlers {
    
    typealias SocketHandlerType = (data: NSArray)->Void
    var handlers : [On:SocketHandlerType] = [On:SocketHandlerType]()
    var errorHandler: (error: ICErrorInfo)->() = { error in }
    
    mutating func addHandler(on: On, handler: SocketHandlerType) -> SocketHandlers {
        
        handlers.updateValue(handler, forKey: on)
        return self
    }
    
    internal func tryPerformSocketError(data: NSArray?) -> Bool {
        
        if data == nil {
            //var error = NSError(domain: "Negotiation", code: 0, userInfo: [NSLocalizedDescriptionKey : "The data is Empty"])
            let error = ICError(string: "Message contains no data").errorInfo!
            errorHandler(error: error)
            return true
        }
        return false
    }
}


protocol SocketCommunicatorHandlerDelegate: class {
    
    //func handlersForSocketListeners() -> SocketHandlers
    func handlersDictionaryForSocketListeners() -> SocketHandlers
}


class SocketCommunicator {
    
    // Create the socket and install it through the SocketConfig struct
    
    let socket = SocketIOClient(socketURL: SocketConfig.server, opts: [
        "nsp"               :SocketConfig.namespace,
        "log"               :SocketConfig.log,
        "forcePolling"      :SocketConfig.forcePolling,
        "forceWebsockets"   :SocketConfig.forceWebsockets])
    
    // Init vars
    
    var conversationToken: String
    weak var delegate: SocketCommunicatorHandlerDelegate?
    
    init(conversationToken: String) {
        self.conversationToken = conversationToken
    }
    
    
    
    func addListeners() {
        
        let dictionaryHandlers = self.delegate?.handlersDictionaryForSocketListeners() ?? SocketHandlers()
        
        // Add connect listener
        self.socket.on(On.Connect.rawValue) {[conversationToken] data, ack in
            
            self.socket.emitWithAck(Emit.Authenticate.rawValue, conversationToken)(timeout:0) { data in
                
                println("SocketCommunicationHandler: authenticated with ack")
            }
        }
        
        // Add error listener
        self.socket.on(On.Error.rawValue) { data, ack in
            
            println("ERROR DATA")
            if let data = data {
                println("ERROR DATA IN DATA")
                if let errorString = data[0] as? String {
                    println("ERROR DATA AS STRING")
                    println(errorString)
                    let error = ICError(string: errorString).errorInfo!
                    dictionaryHandlers.errorHandler(error: error)
                }
            }
        }
        
        for (name, handler) in dictionaryHandlers.handlers {
            
            self.socket.on(name.rawValue, callback: { (data, ack) -> Void in
                
                if dictionaryHandlers.tryPerformSocketError(data) == false {
                    
                    handler(data: data!)

                    // User join
                    if name == On.UserJoin {
                        if let user_id = data?[0] as? String {
                            println(user_id)
                        }
                        ack?("User has been joined", "test")
                    }
                }
            })
        }
        
         //socket.onAny {println("Got event: \($0.event), with items: \($0)")}

    }
    
    
    func removeListeners() {
        self.socket.off("connect")
    }
    
    func start() {
        self.socket.connect()
    }
    
    func stop() {
        self.socket.close(fast: false)
    }

}



// Extension for sending emit messages

extension SocketCommunicator {
    
    func sendMessage(message: String, acknowledged: (data: NSArray?) -> ()) {
        
        self.socket.emitWithAck(Emit.Message.rawValue, message)(timeout: 0, callback: { (data) -> Void in
            
            acknowledged(data: data)
        })
    }
    
    
    func acceptOffer(messageID:String, acknowledged: (data: NSArray?) -> ()) {
     
        self.socket.emitWithAck(Emit.OfferAccept.rawValue, messageID)(timeout: 0) { data in
            
            acknowledged(data: data)
        }
    }
    
    
    func rejectOffer(messageID: String, acknowledged: (data: NSArray?) -> ()) {
        
        self.socket.emitWithAck(Emit.OfferReject.rawValue, messageID)(timeout: 0) { data in
            
            acknowledged(data: data)
        }
    }
    
    
    func acceptContract(messageID:String, acknowledged: (data: NSArray?) -> ()) {
        
        self.socket.emitWithAck(Emit.ContractAccept.rawValue, messageID)(timeout: 0) { data in
            //String error	String new status	Object by who
            acknowledged(data: data)
        }
    }
    
    
    func rejectContract(messageID: String, acknowledged: (data: NSArray?) -> ()) {
        
        self.socket.emitWithAck(Emit.ContractReject.rawValue, messageID)(timeout: 0) { data in
            //String error	String new status	Object by who
            acknowledged(data: data)
        }
    }
    
    
    func acceptRenegotiationRequest(messageID: String, acknowledged: (data: NSArray?) -> ()) {
        
        self.socket.emitWithAck(Emit.RenegotiationAccept.rawValue, messageID)(timeout: 0) { data in
            //String error	String new status	Object by who
            acknowledged(data: data)
        }
    }
    
    
    func rejectRenegotiationRequest(messageID: String, acknowledged: (data: NSArray?) -> ()) {
        
        self.socket.emitWithAck(Emit.RenegotationReject.rawValue, messageID)(timeout: 0) { data in
            //String error	String new status	Object by who
            acknowledged(data: data)
        }
    }
    
    
    func acceptJobCompleted(messageID: String, acknowledged: (data: NSArray?) ->()) {
        
        self.socket.emitWithAck(Emit.MarkCompleted.rawValue, messageID)(timeout: 0) { data in
            //String error	String new status	Object by who
            acknowledged(data: data)
        }
    }
    
    
    func rejectJobCompleted(messageID: String, acknowledged: (data: NSArray?) ->()) {
        
        self.socket.emitWithAck(Emit.MarkNotCompleted.rawValue, messageID)(timeout: 0) { data in
            //String error	String new status	Object by who
            acknowledged(data: data)
        }
    }
    
}


