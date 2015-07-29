//
//  MatchTableViewCell.swift
//  iCasting
//
//  Created by T. van Steenoven on 20-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class MatchOverviewCell: UITableViewCell {

    @IBOutlet weak var customTitle: UILabel!
    @IBOutlet weak var customSubtitle: UILabel!
    @IBOutlet weak var customViewForImage: UIView! //!!! This is NOT a UIImageView
    @IBOutlet weak var customDate: UILabel!
    @IBOutlet weak var customNegotiationIcon: UIImageView!
    @IBOutlet weak var statusIndicatorView: UIView!
    @IBOutlet weak var statusIndicatorText: UILabel!

    var customImageView: UIImageView!

}


extension MatchOverviewCell {
    
    func configureCell(data: MatchCard) {
        
        customImageView = UIImageView(frame: CGRectMake(0, 0, 70, 70))
        customTitle.text = data.title
        customSubtitle.text = String(format: "Talent: %@", data.talent) //data[.JobDescription]
        customDate.text = String(format: "Start: %@", data.dateStart)
        
        var base64: String = data.avatar
        if let image: UIImage = ICImages.ImageWithString(base64).image {
            //customImageView = UIImageView(image: image)
            customImageView.image = image
        } else {
            //customImageView = UIImageView(image: ICImages.PlaceHolderClientAvatar.image)
            customImageView.image = ICImages.PlaceHolderClientAvatar.image
        }
        
        // Configure the cell conform the status of the match (ex: talent accepted, negotiation, pending, closed, finnished)
        setStatus(data.getStatus())
    }
    
    
    func setStatus(status: FilterStatusFields?) {
        
        let tagForReset = 1
        
        if let view = statusIndicatorView.viewWithTag(tagForReset) {
            view.removeFromSuperview()
        }

        if let view = customViewForImage.viewWithTag(tagForReset) {
            view.removeFromSuperview()
        }
        
        statusIndicatorText.text = String()
        
        if let status = status {

            statusIndicatorText.text = NSLocalizedString(status.rawValue, comment: "")
            
            if status == .Negotiations {
                customNegotiationIcon.hidden = false
            } else {
                customNegotiationIcon.hidden = true
            }
            
            if let color = UIColor.color(forMatchStatus: status) {
                
                // Sets the border around the image view
                let borderedView = BorderView(view: customImageView, round: true, initialInset: 5)
                .border(width: 1.5, color: UIColor.whiteColor())
                .border(width: 4, color: color)
                borderedView.tag = tagForReset
                
                // Add the result to the custom view for showing
                customViewForImage.addSubview(borderedView)
                
                // Create the status indicator and add it as a subview
                let statusIndicator = StatusIndicatorView(frame: CGRectMake(0, 0, 11, 11), color: color)
                statusIndicator.tag = tagForReset
                statusIndicator.center = CGPointMake(15/2, 15/2)
                statusIndicatorView.addSubview(statusIndicator)
                
//                if status == FilterStatusFields.Negotiations {
//                    statusIndicator.startAnimating()
//                }

                return
            }
        }
        
        customImageView.makeRound(customImageView.frame.width/2, withBorderWidth:2, andBorderColor: UIColor(white: 0.85, alpha: 1))
        customImageView.tag = tagForReset
        customViewForImage.addSubview(customImageView)
        let statusIndicator = StatusIndicatorView(frame: CGRectMake(0, 0, 15, 15), color: UIColor.grayColor())
        statusIndicator.tag = tagForReset
    }
    
}