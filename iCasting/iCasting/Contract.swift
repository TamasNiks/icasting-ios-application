//
//  Contract.swift
//  iCasting
//
//  Created by Tim van Steenoven on 15/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// Different parts for a message are encapsulated, see the offer file for more

struct MessageContract {
    
    var contract: [String:JSON] = [String:JSON]()
    
    struct NegotiationPoint : Printable {
        let name: String
        let accepted: Bool
        var description: String { return "name: \(name), accepted: \(accepted)" }
    }
    
    var value: [NegotiationPoint] {
        
        var np = [NegotiationPoint]()
        let keys = Array(contract.keys)
        
        np = keys.map( { (key: String) -> NegotiationPoint in
            var isAccepted: Bool = self.contract[key]!["accepted"].boolValue
            return NegotiationPoint(name: key, accepted: isAccepted)
        })
        
        // TODO: Set on false
        np = np.filter({ (val: NegotiationPoint) -> Bool in
            return (val.accepted == true)
        })
        
        return np
    }
}
