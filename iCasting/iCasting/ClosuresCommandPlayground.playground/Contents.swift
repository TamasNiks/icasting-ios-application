//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


protocol RequestCommand {
    func execute(callBack:(success:String)->())
}


class UserRequest: RequestCommand {
    
    let command: RequestCommand?
    
    init(command: RequestCommand?) {
        self.command = command
    }
    
    func execute(callBack:RequestClosure) {
        
        callBack("UserRequest")
        
        if let c = self.command {
            c.execute() { success in
                println(success)
            }
        }
    }
    
    
}


class LoginRequest: RequestCommand {
    
    let command: RequestCommand?
    init(command: RequestCommand?) {
        self.command = command
    }
    
    func execute(callBack:RequestClosure) {
        
        callBack("LoginRequest")
        
        if let c = self.command {
            c.execute() { success in
                println(success)
            }
        }
    }
    
}

class CastingRequest: RequestCommand {
    
    let command: RequestCommand?
    
    init(command: RequestCommand?) {
        self.command = command
    }
    
    func execute(callBack:RequestClosure) {
        
        callBack("CastingRequest")
        
        if let c = self.command {
            c.execute() { success in
                println(success)
            }
        }
    }
}

var casReq: CastingRequest = CastingRequest()
var userReq: RequestCommand = UserRequest(command: casReq)
var loginReq: RequestCommand = LoginRequest(command: userReq)

loginReq.execute { (success) -> () in
    prinln(success)
}




