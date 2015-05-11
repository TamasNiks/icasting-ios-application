//
//  Negotiation.swift
//  iCasting
//
//  Created by Tim van Steenoven on 06/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// Depending on the
enum Role: Int {
    case User, Partner, System
}

// TODO: improve enum
enum TextType: String {
    case
    SystemText = "system text",
    SystemContractFieldsUnaccepted = "system contract fields unaccepted",
    Text = "text"
    
    static func fromType(type:String) -> TextType {
        switch type {
        case TextType.SystemText.rawValue:
            return TextType.SystemText
        case TextType.SystemContractFieldsUnaccepted.rawValue:
            return TextType.SystemContractFieldsUnaccepted
        default:
            return TextType.Text
        }
    }
}

struct Message : Printable {
    let id: String
    let body: String
    let role: Role
    let read: Bool
    let type: TextType
    let owner: String
    var description: String {
        return "id: \(id) body: \(body) role: \(role) read: \(read) type: \(type) owner: \(owner)"
    }
}

struct ConversationToken : Printable {
    let token: String
    let client: String
    let url: String
    var description: String {
        return "token: \(token) client: \(client) url: \(url)"
    }
}

class Conversation {

    //let socket = SocketIOClient(socketURL: "https://ws-demo.icasting.net")
    let matchID:String
    var messages:[Message] = [Message]()

    
    private var _messages:[JSON] = [JSON]()
    private var conversationToken: ConversationToken?

    init(matchID:String) {
        self.matchID = matchID
    }
    
}


extension Conversation {
    
    func requestMessages(callBack: ()->()) {
        
        let url: String = APIMatch.MatchConversation(self.matchID).value
        let access_token: AnyObject = Auth.auth.access_token as! AnyObject
        let params: [String : AnyObject] = ["access_token":access_token]
        
        request(Method.GET, url, parameters: params, encoding: ParameterEncoding.URL)
            .responseJSON() { (request, response, json, error) -> Void in
                
                if (error != nil) {
                    NSLog("Error: \(error)")
                    println(request)
                    println(response)
                }
                
                if let messagesJSON: AnyObject = json {
                    
                    self.requestConversationToken { (request, response, json, error) -> () in
                        
                        if (error != nil) {
                            NSLog("Error: \(error)")
                            println(request)
                            println(response)
                        }
                        
                        println(messagesJSON)
                        
                        if let tokenJSON: AnyObject = json {
                            
                            if let error = ICError(json: JSON(messagesJSON)).getErrors() {
                                println(error)
                            }
                            
                            self._messages = JSON(messagesJSON).arrayValue
                            //println(messagesJSON)
                            self.setToken(JSON(tokenJSON))
                            self.setMessages(JSON(messagesJSON))
                            //self.initializeSocket()
                            callBack()
                        }
                        
                        
                        
                    }
                    
                    
                }
        }
        
    }

    private func requestConversationToken(callBack: (request: NSURLRequest, response: NSURLResponse?, json:AnyObject?, error:NSError?)->()) {
        
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
    
    private func setMessages(json: JSON) {
        
        var m: [Message] = [Message]()
        for (index: String, subJson: JSON) in json {
            
            let owner: String = subJson["owner"].stringValue
            let type: String = subJson["type"].stringValue
            var body: String = subJson["body"].stringValue
            
            let role: Role = getRole(owner)
            let textType: TextType = TextType.fromType(type)
            
            if textType == TextType.SystemText {
                body = NSLocalizedString(body, comment: "The system text will be translated")
            }
            
            let message: Message = Message(
                id:     subJson["_id"].stringValue,
                body:   body,
                role:   role,
                read:   subJson["read"].boolValue,
                type:   textType,
                owner:  owner)
            
            m.append(message)
        }
        messages = m
    }
    
    private func getRole(owner: String) -> Role {
        
        // TODO: Get the id from a casting object
        if Auth.auth.user_id == owner {
            return Role.User
        }
       
        return Role.Partner
    }
    
}

// Handles the sockets

/*extension Conversation {
    
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

