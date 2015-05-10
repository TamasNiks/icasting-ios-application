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

struct NewsKey {
    static let Title: String = "title"
    static let Summary: String = "summary"
    static let Body: String = "body"
    static let ImageID: String = "image"
    static let ID: String = "id"
    static let Published: String = "published"
}

// TODO: Make use of JSON class and add getter functionalities to data
class News : ModelProtocol {
    
    var newsItems : [AnyObject] = []
    
    /* Asks for all the items */
    func all(callBack: RequestClosure) {

        
        var url: String = APINews.NewsItems.value
        request(.GET, url).responseJSON { (_, _, JSON, _) -> Void in
            if let result: AnyObject = JSON {
                self.newsItems = result as! [AnyObject]
                callBack(failure: nil)
            }
        }
    }
    
    /* Asks for one item for a given id */
    func one(id: String, callBack: RequestClosure) {
        
        var url: String = APINews.NewsItem(id).value
        request(.GET, url).responseJSON { (_, _, JSON, _) -> Void in
            if let result: AnyObject = JSON {
                self.newsItems = result as! [AnyObject]
                callBack(failure: nil)
            }
        }
        
    }
}


extension News {
    
    func image(id: String, size: ImageSize, callBack : ((success:AnyObject, failure:NSError?)) -> () ) {

        var url: String = APIMedia.ImageWithSize(id, size.rawValue).value
        request(.GET, url).response { (request, response, data, error) -> Void in
            if let result: AnyObject = data {
                callBack((success:result, failure:nil))
            }
        }
    }
}

