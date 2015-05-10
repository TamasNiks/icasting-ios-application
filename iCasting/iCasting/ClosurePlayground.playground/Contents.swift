//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

typealias S = () -> (String)
typealias F = () -> ()
typealias PT = (S)

class Promise {
    
    var _s:S = {""}
    
    init() {
        
        self._s = {
            "lalalaa"
        }
        
    }
    
    func execute(callBack: (s:S) -> Promise) {
        callBack(s: self._s)
    }
    
    func then() {

    }
}


Promise().execute { (s) -> Promise in
    
    s()
    
    return Promise()
    
}



typealias ReturnClosure = () -> (String)





var rc: ReturnClosure = {
    
    return " hello "
}


rc()


func lala(test:ReturnClosure) {
    
    
    
}





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
