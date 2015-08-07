//
//  News.swift
//  iCasting
//
//  Created by T. van Steenoven on 09-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

enum ImageSize: String {
    case Full = "",
    Thumbnail = "200x200"
}

class News {
    var newsItems: [NewsItem] = [NewsItem]()
}

final class NewsItem: Printable, ResponseCollectionSerializable {
    
    struct Key {
        static let Title         = "title"
        static let Summary       = "summary"
        static let Body          = "body"
        static let ImageID       = "image"
        static let ID            = "id"
        static let Published     = "published"
    }
    
    let title: String
    let body: String
    let imageID: String
    let published: String
    var read: Bool = false
    
    init(title: String, body: String, imageID: String, published: String) {
        self.title = title
        self.body = body
        self.imageID = imageID
        self.published = published
    }

    @objc static func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [NewsItem] {
        
        var list = [NewsItem]()
        if let representation = representation as? [AnyObject] {
            
            list = representation.map { (transform: AnyObject) -> NewsItem in
                
                return NewsItem(
                    title:      transform[Key.Title] as! String,
                    body:       transform[Key.Body] as! String,
                    imageID:    transform[Key.ImageID] as! String,
                    published:  transform[Key.Published] as! String)
            }
        }
        
        return list
    }
    
    var description: String {
        return "Title: \(title)"
    }
}


