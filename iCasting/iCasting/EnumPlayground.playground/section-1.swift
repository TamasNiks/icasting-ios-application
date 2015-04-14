// Playground - noun: a place where people can play

import Foundation

let Naam = "Hello playground"


enum Result<A> {
    case Error(NSError)
    case Result(A)
}



var str : NSString = "Hello, my name is"

str.substringToIndex(str.length-1)

//var range: NSRange = NSRange()
//range.length = count(str)
//range.location = 0
//
//str.substringWithRange(range)


protocol EndpointProtocol {
    func endpoint() -> String
}

enum APITest: Int, EndpointProtocol {
    
    case LalaID, TestIDLalaID, NoID
    
    func endpoint() -> String {
        switch self {
        case .LalaID:
            return "lala/:id"
        case .NoID:
            return "lala/blabla"
        default:
            return "test/:id/lala/:id"
        }
        
    }
}

struct ApiURL {
    
    var uri : EndpointProtocol
    var id : [String]
    
    func resolve() -> String {
        
        var arr : [AnyObject] = uri.endpoint().componentsSeparatedByString(":id")

        var resolved: String = ""
        if arr.count > 1 {

            for i in 0..<arr.count-1 {
                var part : String = arr[i] as! String
                var _id : String = id[i]
                resolved = resolved + part + _id
            }
        }
        else {
            resolved = uri.endpoint()
        }
        
        return resolved
    }
}

var url = ApiURL(uri: APITest.TestIDLalaID, id: ["1","2"]).resolve()




enum Test : Int {
    
    case uri1 = 1, uri2, uri3
    
    
}

//let enumVal = test.uri1

let persons : [Test:String] = [Test.uri1:"van Steenoven"]


println(persons[Test.uri1])




enum Auth : Int {
    
    case
    Login,
    LoginFacebook,
    LoginTwitter,
    LoginGoogle,
    Logout
    
    func endpoints() -> String {
        
        switch self {
            
        case .Login:
            return "login"
        case .LoginFacebook:
            return "login/facebook"
        case .LoginTwitter:
            return "login/twitter"
        case .LoginGoogle:
            return resolve("login/google")
        case .Logout:
            return resolve("logout")
        }
    }
    
    func resolve(name:String) -> String {
        
        let baseURL = "https://api-demo.icasting.net/api/v1/"
        return baseURL + name
        
    }
}


var auth = Auth.LoginGoogle.endpoints()


