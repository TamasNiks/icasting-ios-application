// Playground - noun: a place where people can play

import Foundation

var str = "Hello, playground"

struct UserStruct {
    static let sharedInstance : User = User()
}

class User {

    var number : Int?
    
//    init() {
//    
//    }

    class func sharedInstance() -> User {
        return UserStruct.sharedInstance
    }
    
}


var user1 : User = User.sharedInstance()

user1.number = 1


var user2 : User = User.sharedInstance()

user2.number = 2
user2.number!

user1.number!
