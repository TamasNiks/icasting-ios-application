// Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

enum Auth : Int {
    
    case Login, Logout
    
}


struct Endpoint {
    
    //static let dic = [Auth.Login:Endpoint.test("lalala")]
    
    func test(name : String) -> String {
        return name + "lalala"
    }
    
}



//let e = Endpoint()
//println(Endpoint.dic[Auth.Login])



struct Endpoint {
    
    static let BaseURL : String = "https://api-demo.icasting.net/api/v1/"
    let Authorization = [
        Auth.Login:Endpoint.resolve("login"),
        Auth.Logout:Endpoint.resolve("logout")
    ]
    
    //    let News = [
    //        //News.newsItem:Endpoint.resolve("newsItem")
    ////        News.newsItems:Endpoint.resolve("newsItems")
    //    ]
    
    
    /* AUTHORIZATION */
    
    //    let AuthorizationLogin : String = Endpoint.resolve("login")
    //    let AuthorizationLogout : String = Endpoint.resolve("logout")
    //    let AuthorizationLoginFacebook : String = Endpoint.resolve("login/facebook")
    //    let AuthorizationLoginTwitter : String = Endpoint.resolve("login/facebook")
    //var AuthorizationTest : String =
    
    
    static func resolve(endpoint : String) -> String {
        
        return Endpoint.BaseURL + endpoint
        
    }
    
}
