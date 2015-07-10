//
//  MatchDetailAcceptCell.swift
//  iCasting
//
//  Created by Tim van Steenoven on 16/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class MatchAcceptCell: DilemmaCell {

    @IBOutlet weak var customAcceptButton: UIButton!
    @IBOutlet weak var customRejectButton: UIButton!
}


extension MatchAcceptCell {
    
    func configureCell(item:MatchCard) {
        
        // Configure the cell depending on the status of a match
        if let status: FilterStatusFields = item.getStatus() {
            
            let localizeComment = "The text to display after the user has made an true or false decision."
            
            switch status {
                
            case .TalentAccepted:
                super.accepted = true
                super.acceptedTitle = NSLocalizedString("match.decisionstate.accepted", comment: localizeComment)
            case .Negotiations:
                super.acceptedWithButton = true
                super.acceptedTitle = NSLocalizedString("match.decisionstate.negotiation", comment: localizeComment)
            case .Closed:
                super.accepted = false
                super.rejectedTitle = NSLocalizedString("match.decisionstate.closed", comment: localizeComment)
            case .Completed:
                super.accepted = true
                super.acceptedTitle = NSLocalizedString("match.decisionstate.completed", comment: localizeComment)
            case .Pending:
                super.accepted = nil
                super.acceptedTitle = NSLocalizedString("match.decisionstate.accepted", comment: localizeComment)
            }
        }
    }
}