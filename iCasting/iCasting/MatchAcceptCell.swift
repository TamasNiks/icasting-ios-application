//
//  MatchDetailAcceptCell.swift
//  iCasting
//
//  Created by Tim van Steenoven on 16/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class MatchAcceptCell: UITableViewCell {

    @IBOutlet weak var customAcceptButton: UIButton!
    @IBOutlet weak var customRejectButton: UIButton!
}


extension MatchAcceptCell {
    
    func configureCell(item:MatchCard) {

        let status: FilterStatusFields? = item.getStatus()
        if status == .TalentAccepted || status == .Negotiations {

            customAcceptButton.enabled = false
            customAcceptButton.backgroundColor = UIColor.lightGrayColor()

            customRejectButton.enabled = false
            customRejectButton.backgroundColor = UIColor.lightGrayColor()
        }
        
    }
    
}