//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


class Message {
    
    typealias MessageChangeObserverClosure = (message: Message, index: Int) -> ()
    
    var notifyChange: MessageChangeObserverClosure?
    var id: Int

    init(id: Int) {
        self.id = id
    }
}



class Observer {

    var messageList: [Message] = [Message]()

    
    
    init() {
        
        self.messageList = [Message(id: 1), Message(id: 2), Message(id: 3)]
    }
    
}



// CLIENT

let observer = Observer()

for m in observer.messageList {
    
    m.notifyChange = { (message: Message, index: Int) in
        
        println("OBSERVED CHANGE: \(index)")
    }
}

let message: Message = observer.messageList[0]
message.id = 1233455

if let notifyChange = observer.messageList[1].notifyChange {

    notifyChange(message: message, index: 90)
    
}


