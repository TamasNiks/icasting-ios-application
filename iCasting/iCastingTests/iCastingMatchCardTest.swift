//
//  iCastingMatchCardTest.swift
//  iCasting
//
//  Created by Tim van Steenoven on 17/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit
import XCTest

class iCastingMatchCardTest: XCTestCase {

    let testJson1 = ["_id": "12345", "job" : ["formSource" : ["profile" : ["hair" : [ "face" : ["isBalding" : false, "isBold" : false] ] ] ] ] ]
    let testJson2 = ["_id": "12345", "job" : ["formSource" : ["profile" : ["hair" : [ "face" : ["isBalding" : false, "isBold" : false] ] ] ] ] ]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNewMatchClass() {
        //["job", "formSource", "profile"]
        
        var mc1: MatchCard = MatchCard(matchCard: JSON(testJson1))
        var mc2: MatchCard = MatchCard(matchCard: JSON(testJson2))
        
        println(mc1)

        XCTAssertEqual(mc1, mc2, "MatchCard is equal")
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
