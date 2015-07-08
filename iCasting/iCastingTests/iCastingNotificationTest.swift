//
//  iCastingNotificationTest.swift
//  iCasting
//
//  Created by Tim van Steenoven on 21/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit
import XCTest

class iCastingNotificationTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNotificationTypeDescription() {
        // This is an example of a functional test case.
        
        
        let dummy = "[{\"_id\":\"555a30dd42c47224c661a5b8\",\"user\":\"551d58a226042f74fb745533\",\"type\":\"achievement-complete\",\"parameters\":{\"achievement\":\"53345406ca3d3b22a71d7b37\",\"achievementType\":\"sendReaction\",\"title\":\"React to 5 matches\",\"desc\":\"React to 5 matches\",\"xpReward\":25,\"amount\":5},\"pushState\":{\"update\":\"2015-05-18T18:35:09.000Z\",\"state\":\"new\"},\"read\":false,\"created\":\"2015-05-18T18:35:09.000Z\",\"id\":\"555a30dd42c47224c661a5b8\"}]"
        
        var str: String
        if let data: NSData = dummy.dataUsingEncoding(NSUTF8StringEncoding) {
            
            if let json: [AnyObject] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as? [AnyObject] {
            
                var parsedJSON = JSON(json)[0]
                //var type: NotificationTypes = NotificationTypes.getType(parsedJSON["type"].stringValue)!
                if let type: NotificationTypes = NotificationTypes(rawValue: parsedJSON["type"].stringValue) {
                    var dict = parsedJSON["parameters"].dictionaryValue
                    
                    let title = type.getTitle()
                    let desc = type.getDescription(dict)
                    println(title)
                }
            }
        }
        
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
