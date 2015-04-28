//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var json : [String: AnyObject] = [
    "stat": "ok",
    "blogs": [
        "blog": [
            [
                "id" : 73,
                "name" : "Bloxus test",
                "needspassword" : true,
                "url" : "http://remote.bloxus.com/"
            ],
            [
                "id" : 74,
                "name" : "Manila Test",
                "needspassword" : false,
                "url" : "http://flickrtest1.userland.com/"
            ]
        ]
    ]
]







//if let output: [String:AnyObject] = dictionary(json, "blogs") {
//    
//    println(output)
//    
//} else {
//    
//    println("not found")
//    
//}


//struct Blog {
//    let id: Int
//    let name: String
//    let needsPassword : Bool
//    let url: NSURL
//}
//
//
//func parseBlog(blog: AnyObject) -> Blog? {
//    return asDict(blog) >>= {
//        mkBlog <*> int($0,"id")
//            <*> string($0,"name")
//            <*> bool($0,"needspassword")
//            <*> (string($0, "url") >>= toURL)
//    }
//}
//
//let parsed : [Blog]? = dictionary(json, "blogs") >>= {
//    array($0, "blog") >>= {
//        join($0.map(parseBlog))
//    }
//}