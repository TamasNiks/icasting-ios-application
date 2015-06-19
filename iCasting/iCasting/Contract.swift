//
//  Contract.swift
//  iCasting
//
//  Created by Tim van Steenoven on 15/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// Different parts off a message are encapsulated.

struct MessageContract {
    
    var contract: [String:JSON] = [String:JSON]()
    
    struct NegotiationPoint : Printable {
        let name: String
        let accepted: Bool
        var description: String { return "name: \(name), accepted: \(accepted)" }
    }
    
    var value: [NegotiationPoint] {
        
        var np = [NegotiationPoint]()

        mapValuesToNegotiationPoints(&np)
        filterNegotiationPoints(&np)

        return np
    }
    
    private func mapValuesToNegotiationPoints(inout np: [NegotiationPoint]) {
        
        let keys = Array(contract.keys)
        np = keys.map( { (key: String) -> NegotiationPoint in
            let isAccepted: Bool = self.contract[key]!["accepted"].boolValue
            let localizedKey = self.getLocalizationForValue(key)
            return NegotiationPoint(name: localizedKey, accepted: isAccepted)
        })
    }
    
    private func filterNegotiationPoints(inout np: [NegotiationPoint]) {
    
        np = np.filter({ (val: NegotiationPoint) -> Bool in
            return (val.accepted == false)
        })
    }
    
    private func getLocalizationForValue(value: String) -> String {
        
        let prefix = "negotiations.offer.title.%@"
        let formatted = String(format: prefix, value)
        let translated = NSLocalizedString(formatted, comment: "")
        
        let postfix = NSLocalizedString("negotiations.agreement", comment: "")
        let result = String(format: "%@ %@", translated, postfix)
        return result
    }
}
