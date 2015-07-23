//
//  ContractState.swift
//  iCasting
//
//  Created by Tim van Steenoven on 12/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


// The contract state is to help decide the state of mutual agreement of both client and talent, depending on three parameters
enum ContractState {
    
    case
    NeitherDecided, // Show buttons both
    ClientAccepted, // Show buttons talent
    ClientRejected, // Remove buttons both
    TalentAccepted, // Show button client
    TalentRejected, // Remove buttons both
    BothAccepted    // Remove buttons both
    
    static func getState(#clientAccepted: Bool?, talentAccepted: Bool?, accepted: Bool?) -> ContractState {
        
        if let accepted = accepted {
            
            if accepted == true {
                return ContractState.BothAccepted
            }
        }
        
        if let ca = clientAccepted {
            
            if talentAccepted == nil {
                
                if ca == true {
                    return ContractState.ClientAccepted
                } else {
                    return ContractState.ClientRejected
                }
            }
        }
        
        if let ta = talentAccepted {
            
            if clientAccepted == nil {
                
                if ta == true {
                    return ContractState.TalentAccepted
                } else {
                    return ContractState.TalentRejected
                }
            }
        }
        
        if let ca = clientAccepted, ta = talentAccepted {
            
            if ca == true && ta == true {
                return ContractState.BothAccepted
            }
            if ca == false {
                return ContractState.ClientRejected
            }
            if ta == false {
                return ContractState.TalentRejected
            }
        }
        
        return ContractState.NeitherDecided
    }
}

