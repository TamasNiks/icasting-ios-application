//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

struct GetRequest {
    
    func request() {
        
        println("You did a request")
    }
    
}

protocol Blabla {
    
}

struct TestCase : Blabla {
    
    var method:String
    var request:GetRequest {
        get {
            return GetRequest()
        }
    }
    


    
}


//TestCase(method: "GET").type.request()
