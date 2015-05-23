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

}


extension MatchHeaderCell {
    
    func configureCell(item:MatchContractType) {
        
        contentView.backgroundColor = UIColor.ICShadowRedColor()
        
        customIconCompany.font = UIFont.fontAwesomeOfSize(20)
        customIconCompany.text = String.fontAwesomeIconWithName(FontAwesome.Building)
        customIconClient.font = UIFont.fontAwesomeOfSize(25)
        customIconClient.text = String.fontAwesomeIconWithName(FontAwesome.User)
        
        customCompany.text = item.header[.ClientCompany] ?? "Niet ingevuld"
        customClient.text = item.header[.ClientName] ?? "Niet ingevuld"
        //let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        
        var base64: String = (item.header[.ClientAvatar] ?? "")!
        
        if let image: UIImage = ICImages.ImageWithString(base64).image {
            customImageView.image = image
        } else {
            customImageView.image = ICImages.PlaceHolderClientAvatar.image
        }
        customImageView.makeRound(40)
        
    }
    
}