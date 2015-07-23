//
//  MatchDetailHeaderCell.swift
//  iCasting
//
//  Created by Tim van Steenoven on 16/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class MatchHeaderCell: UITableViewCell {

    @IBOutlet weak var customIconCompany: UILabel!
    @IBOutlet weak var customIconClient: UILabel!
    @IBOutlet weak var customClient: UILabel!
    @IBOutlet weak var customCompany: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    //@IBOutlet weak var customTalentLabel: UILabel!

}


extension MatchHeaderCell {
    
    func configureCell(item: MatchDetailType) {
        
        contentView.backgroundColor = UIColor.ICShadowRedColor()
        
        customIconCompany.font = UIFont.fontAwesomeOfSize(20)
        customIconCompany.text = String.fontAwesomeIconWithName(FontAwesome.Building)
        customIconClient.font = UIFont.fontAwesomeOfSize(20)
        customIconClient.text = String.fontAwesomeIconWithName(FontAwesome.User)
        
        customCompany.text = item.general[.ClientCompany] ?? "-"
        customClient.text = item.general[.ClientName] ?? "-"
        
//        var talent = NSMutableAttributedString(string: "Talent: ", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)])
//        talent.appendAttributedString(NSAttributedString(string: item.job["talent"]!, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(14)]))
//        customTalentLabel.attributedText = talent
        //customTalentLabel.text = String(format: "Talent: %@", item.job["talent"]!)
        
        var base64: String = (item.general[.ClientAvatar] ?? "") ?? ""
        
        if let image: UIImage = ICImages.ImageWithString(base64).image {
            customImageView.image = image
        } else {
            customImageView.image = ICImages.PlaceHolderClientAvatar.image
        }
        customImageView.makeRound(40)
        
    }
    
}