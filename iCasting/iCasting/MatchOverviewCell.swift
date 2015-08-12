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
    
    var customTitleFontBold: Bool = false {
        willSet {
           
            let pointSize = customTitle.font.pointSize
            
            if newValue == true {
                 customTitle.font = UIFont.boldSystemFontOfSize(pointSize)
            } else {
                customTitle.font = UIFont.systemFontOfSize(pointSize)
            }
        }
    }
    
}


extension MatchOverviewCell {
    
    override func configureCell(model: AnyObject) {
        
        if let data = model as? MatchCard {
            
            customImageView = UIImageView(frame: CGRectMake(0, 0, 70, 70))
            
            setCustomTitle(data.title, read: true)
            
            customSubtitle.text = String(format: "Talent: %@", data.talent) //data[.JobDescription]
            customDate.text = String(format: "Start: %@", data.dateStart)
            
            setAvatar(data.avatar)
            
            // Configure the cell conform the status of the match (ex: talent accepted, negotiation, pending, closed, finnished)
            setStatus(data.getStatus())
        }
    }
    
    
    func setCustomTitle(title: String, read: Bool) {
        
        customTitleFontBold = read ? false : true
        customTitle.text = title
    }
    
    
    func setAvatar(base64: String) {

        if let image: UIImage = ICImages.ImageWithString(base64).image {
            //customImageView = UIImageView(image: image)
            customImageView.image = image
        } else {
            //customImageView = UIImageView(image: ICImages.PlaceHolderClientAvatar.image)
            customImageView.image = ICImages.PlaceHolderClientAvatar.image
        }
    }
    
    
    func setStatus(status: FilterStatusFields?) {
        
        let tagForReuse = 1
        
        if let view = statusIndicatorView.viewWithTag(tagForReuse) {
            view.removeFromSuperview()
        }

        if let view = customViewForImage.viewWithTag(tagForReuse) {
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
            
            if let color = MatchStatusColor.color(status) {
                
                // Sets the border around the image view
                let borderedView = createBorderedView(color)
                // Add the result to the custom view for showing
                customViewForImage.addSubview(borderedView)
                // Create the status indicator and add it as a subview
                setStatusIndicatorView(color)
                
                return
            }
        }
        
        let nonBorderedCustomImageView = createNonBorderedView()
        customViewForImage.addSubview(nonBorderedCustomImageView)
        setStatusIndicatorView(UIColor.brownColor())
    }
    
    
    private func setStatusIndicatorView(color: UIColor) {
        
        let tagForReuse = 1
        let si = StatusIndicatorView(frame: CGRectMake(0, 0, 11, 11), color: color)
        si.tag = tagForReuse
        si.center = CGPointMake(15/2, 15/2)
        statusIndicatorView.addSubview(si)
    }
    
    
    private func createBorderedView(color: UIColor) -> UIView {
        
        let tagForReuse = 1
        let borderedView = BorderView(view: customImageView, round: true, initialInset: 5)
            .border(width: 1.5, color: UIColor.whiteColor())
            .border(width: 4, color: color)
        borderedView.tag = tagForReuse
        
        return borderedView
    }
    
    
    private func createNonBorderedView() -> UIView {
        
        let tagForReuse = 1
        customImageView.frame = CGRectInset(customImageView.frame, 5.5, 5.5)
        customImageView.makeRound(customImageView.frame.width/2, withBorderWidth:0, andBorderColor: UIColor(white: 1, alpha: 1))
        customImageView.tag = tagForReuse
        return customImageView
    }
    
}