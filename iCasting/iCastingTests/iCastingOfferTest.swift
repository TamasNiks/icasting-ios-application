//
//  iCastingOfferTest.swift
//  iCasting
//
//  Created by Tim van Steenoven on 19/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit
import XCTest

class iCastingOfferTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testContractOfferState() {
    
        var offer: Offer = Offer(stateComponents: StateComponents(acceptClient: true, acceptTalent: nil, accepted: nil))
        XCTAssertTrue(offer.contractState != nil, "Should not be nil")
    
    }

    
    func testContractState() {
        
        XCTAssertEqual(ContractState.getState(clientAccepted: nil, talentAccepted: nil, accepted: nil), ContractState.NeitherDecided, "Equal offer type")
        
        XCTAssertEqual(ContractState.getState(clientAccepted: true, talentAccepted: nil, accepted: nil), ContractState.ClientAccepted, "Equal offer type")
        XCTAssertEqual(ContractState.getState(clientAccepted: false, talentAccepted: nil, accepted: nil), ContractState.ClientRejected, "Equal offer type")
        XCTAssertEqual(ContractState.getState(clientAccepted: nil, talentAccepted: true, accepted: nil), ContractState.TalentAccepted, "Equal offer type")
        XCTAssertEqual(ContractState.getState(clientAccepted: nil, talentAccepted: false, accepted: nil), ContractState.TalentRejected, "Equal offer type")

        // After both made a decision, there are three possible outcomes.
        XCTAssertEqual(ContractState.getState(clientAccepted: true, talentAccepted: true, accepted: true), ContractState.BothAccepted, "Equal offer type")
        XCTAssertEqual(ContractState.getState(clientAccepted: true, talentAccepted: false, accepted: false), ContractState.TalentRejected, "Equal offer type")
        XCTAssertEqual(ContractState.getState(clientAccepted: false, talentAccepted: true, accepted: false), ContractState.ClientRejected, "Equal offer type")
        
    }
    
    
    func testConcatenateTypeKey() {
        // This will test if the type key can properlay concatenate with the offer name
        
        
        var offerData: [String:AnyObject] = [String:AnyObject]()
        offerData["dateStart"] = "2015-08-01T00:00:00.000Z"
        offerData["type"] = "multiple" // or "single"
        
        var dummyDataArray: NSArray = NSArray(objects: "", "dateTime", offerData, "558176be04b04d4f65fad146", "55846ac9a6f5f3ec73f0d04c")
        var offerSocketDataExtractor = OfferSocketDataExtractor(offer: dummyDataArray)
        
        var bool = false
        if let value: Offer = offerSocketDataExtractor.value {
            
            if let values = value.values {
                for keyval: KeyVal in values {
                    
                    if keyval.key == "type.dateTime" {
                        //                    println(keyval.key)
                        //                    println(keyval.val)
                        bool = true
                    }
                }
            }
        }
        
        XCTAssert(bool, "The type should now be replaced to type.dateStart")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
