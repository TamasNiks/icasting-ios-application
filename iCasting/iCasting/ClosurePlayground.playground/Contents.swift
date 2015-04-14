//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


func invokeSomething(callBack: (name:String) -> String ) -> () -> String {
    
    
    func welkomMessage() -> String {
        
        return "Hello "+callBack(name: "Tim")
        
    }
    
    return welkomMessage
    
}



var f = invokeSomething() { name in
    
    return "Tim van Steenoven"
    
}

f()




func testing(callBack: (data:String)->()) {
    
    callBack(data: "This is data")
    
}

testing { data in
    
    
    
}
