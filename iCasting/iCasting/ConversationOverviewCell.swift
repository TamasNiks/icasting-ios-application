//
//  ConversationOverviewCell.swift
//  iCasting
//
//  Created by Tim van Steenoven on 23/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class ConversationOverviewCell: UITableViewCell {

    @IBOutlet weak var customTitle: UILabel!
    @IBOutlet weak var customSubtitle: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var statusText: UILabel!
    //@IBOutlet weak var customDate: UILabel!

    // Use this size value to measure the rounding corners of elements
    let customImageViewSize: CGSize = CGSizeMake(60, 60)
}


extension ConversationOverviewCell {
    
    func configureCell(model: AnyObject) {
        
        
        let matchCard = model as! MatchCard
        
        let data: [Fields: String] = matchCard.getData([.JobTitle, .ClientName, .ClientCompany, .ClientAvatar])
        
        func setSubtitle() {
            
            customSubtitle.font = UIFont.fontAwesomeOfSize(customSubtitle.font.pointSize)
            
            let buildingIcon = String.fontAwesomeIconWithName(FontAwesome.Building)
            let userIcon = String.fontAwesomeIconWithName(FontAwesome.User)

            let clientCompany = data[.ClientCompany]
            let clientName = data[.ClientName]
            
            var cellText = String()
            
            if clientCompany != "-" {
                cellText += buildingIcon
                cellText += " \(clientCompany!)" //\u{2003}
            } else if clientName != "-" {
                cellText += userIcon
                cellText += " \(clientName!)"
            } else {
                cellText += String()
            }
            
            customSubtitle.text = cellText//data[.ClientCompany]
        }
        
        func setStatusText() {
            if let status = matchCard.getStatus() {
                
                statusText.font = UIFont.fontAwesomeOfSize(statusText.font.pointSize)
                statusText.text = ""
                
                let checkMark = String.fontAwesomeIconWithName(FontAwesome.Check)
                
                println("RAWVALUE: "+status.rawValue)
                
                if status == FilterStatusFields.Completed {
                    
                    if matchCard.talentHasRated {
                        statusText.textColor = UIColor.ICGreenColor()
                        statusText.text = checkMark+" "+"Onderhandeling afgerond"
                    } else {
                        statusText.textColor = UIColor.orangeColor()
                        statusText.text = checkMark+" "+"Je moet de opdracht nog beoordelen"
                    }
                    
                }
            }
        }
        
        customTitle.text = data[.JobTitle]
        setSubtitle()
        setStatusText()
        
        let base64: String = data[.ClientAvatar]!
        if let image: UIImage = ICImages.ImageWithString(base64).image {
            customImageView.image = image
        } else {
            customImageView.image = ICImages.PlaceHolderClientAvatar.image
        }
        
        customImageView.makeRound(customImageViewSize.width / 2, withBorderWidth: nil)
    }
}