//
//  MatchTableViewCell.swift
//  iCasting
//
//  Created by T. van Steenoven on 20-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class MatchCell: UITableViewCell {

    @IBOutlet weak var customTitle: UILabel!
    @IBOutlet weak var customSubtitle: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var customDate: UILabel!
    @IBOutlet weak var customNegotiationIcon: UIImageView!
    
}


extension MatchCell {
    
    func configureCell(data: [Fields:String]  ) {
        
        self.customNegotiationIcon.hidden = true
        self.customImageView.makeRound(0)
        
        self.customTitle.text = data[.JobTitle]
        self.customSubtitle.text = data[.JobDescription]
        self.customDate.text = String(format: "Start: %@", data[.JobDateStart] ?? "no date")
        self.customImageView.alpha = 0
        var base64: String = data[.ClientAvatar]!
        if let image: UIImage = ICImages.ImageWithString(base64).image {
            self.customImageView.image = image
        } else {
            self.customImageView.image = ICImages.PlaceHolderClientAvatar.image
        }
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.customImageView.alpha = 1
        })
        
        // Configure the cell conform the status of the match (ex: talent accepted, negotiation, pending, closed, finnished)
        setStatus(data[.Status])
        
    }
    
    
    func setStatus(status: String?) {
        
        if let status = status {
            
            if let statusField: FilterStatusFields = FilterStatusFields.allValues[status] {
                
                if statusField == .Negotiations || statusField == .TalentAccepted || statusField == .Closed {
                    
                    if statusField == .TalentAccepted {
                        println("TalentAccepted")
                        self.customImageView.makeRound(35, borderWidth: 4, withBorderColor: UIColor.orangeColor())
                    }
                    
                    if statusField == .Negotiations {
                        println("Negotiations")
                        self.customImageView.makeRound(35, borderWidth: 4, withBorderColor: UIColor(red: 123/255, green: 205/255, blue: 105/255, alpha: 1))
                        self.customNegotiationIcon.hidden = false
                    }
                    
                    if statusField == .Closed {
                        println("Negotiations")
                        self.customImageView.makeRound(35, borderWidth: 4, withBorderColor: UIColor.redColor())
                        self.customNegotiationIcon.hidden = false
                    }
                    return
                }
                
                
                
            }
        }
        
        self.customImageView.makeRound(35, borderWidth:0)
        
    }
    
}