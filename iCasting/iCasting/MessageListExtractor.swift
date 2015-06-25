//
//  MessageBuilder.swift
//  iCasting
//
//  Created by Tim van Steenoven on 28/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


// This class is responsible for getting the data from the json object and put it in a list wrapped around a Message object. This message object contains all the necessary information to view a message

protocol ListExtractorProtocol {
    typealias J
    typealias I
    func buildList(fromJSON json: J)
    func addItem(item: I)
}



class MessageListExtractor: NSObject, ListExtractorProtocol {
    
    typealias J = JSON
    typealias I = Message
    
    dynamic var list:[Message] = [Message]()
    
    func buildList(fromJSON json: JSON) {
        
        var m: [Message] = [Message]()
        
        for (index: String, subJson: JSON) in json {
            
            if let message: Message = constructMessage(fromJSON: subJson) {
                m.append(message)
            }
        }
        
        self.list = m
    }
    
    
    private func constructMessage(fromJSON json: JSON) -> Message? {
        
        let message: Message? = AbstractMessageFactory.createMessage(fromJSON: json)
        return message
    }
    
    
    func addItem(message: Message) {
        self.list.append(message)
    }
    
    func replaceItem(message: Message) {
        
        //self.list.r
        
    }
    
    func itemByID(id: String) -> Message? {
       
        let message: Message? = self.list.filter({ (element: Message) -> Bool in
        
            return element.id == id
            
        }).first
        
        return message
    }
    
    func indexForItem(message: Message) -> Int? {
        
        for index in 0..<self.list.endIndex {
            if self.list[index].id == message.id {
                return index
            }
        }
        return nil
    }
}





