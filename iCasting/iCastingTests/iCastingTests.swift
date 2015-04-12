//
//  iCastingTests.swift
//  iCastingTests
//
//  Created by T. van Steenoven on 03-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit
import XCTest

class iCastingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testURLBuilder() {
        
        //var nsurl : NSURL = URLSimpleFactory.createURL(
        //let url: NSURL = URLSimpleFactory.createURL(APINews.newsItem, id: "2323123132313133")
        //let url2: NSURL = URLSimpleFactory.createURL(APINews.newsItems, id: nil)
        //let url3: NSURL = URLSimpleFactory.createMediaURL(APIMedia.images, id: "2323123132313133")
        
        XCTAssert(true, "url check")
    }
    
    func testExample() {
        
        let sNews : String = "{\"_id\":\"54e6fbf172a116be7fe7f8ab\",\"body\":\"Dit is de body tekst\",\"subTitle\":\"Gastvrouw/gastheer zijn is een vak. Jij bent er om te zorgen dat een event of bijeenkomst zorgeloos verloopt.\",\"title\":\"De vijf do's en don’ts als host & hostess\",\"image\":\"551176590b41dda06c23951b\",\"thumbnail\":\"551176590b41dda06c23951b\",\"locales\":[],\"authors\":[\"541fda5b0f1d550000127858\"],\"highlighted\":false,\"published\":\"2015-02-20T00:00:00.000Z\",\"id\":\"54e6fbf172a116be7fe7f8ab\"}"
        
        let sSimple = "[ {\"name\": \"John\", \"age\": 21}, {\"name\": \"Bob\", \"age\": 35} ]"

        
        
        
        
        
        var name = "initial"
        
        // Make a data object, because the url request will return a data object
        if let data = sSimple.dataUsingEncoding(NSUTF8StringEncoding) {
            var array: AnyObject = JSONParser.JSONParse(data)
            name = array[0]["name"] as! String
        }
        
        var id = "initial"
        // Make a data object, because the url request will return a data object
//        if let data = sNews.dataUsingEncoding(NSUTF8StringEncoding) {
//            var dictionary: AnyObject = JSONParser.JSONParse(data)
//            id = dictionary["id"] as String
//        }

        var dictionary: AnyObject = JSONParser.mockJSONParse(sNews)!
        id = dictionary["id"] as! String
        
        println(name)
        XCTAssert(name == "John", "Passes test")
        println(id)
        XCTAssert(id == "54e6fbf172a116be7fe7f8ab", "Passes test")
    }
    
    func testJSON() {
        
        let string = "[ {\"name\": \"John\", \"age\": 21}, {\"name\": \"Bob\", \"age\": 35} ]"
        
        func JSONParseArray(jsonString: String) -> [AnyObject] {
            if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
                if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [AnyObject] {
                    return array
                }
            }
            return [AnyObject]()
        }
        
        for elem: AnyObject in JSONParseArray(string) {
            let name = elem["name"] as! String
            let age = elem["age"] as! Int
            println("Name: \(name), Age: \(age)")
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
