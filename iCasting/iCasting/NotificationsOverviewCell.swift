//
//  NotificationsOverviewCell.swift
//  iCasting
//
//  Created by Tim van Steenoven on 12/08/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class NotificationsOverviewCell: UITableViewCell {

    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


extension NotificationsOverviewCell {
    
    override func configureCell(model: AnyObject) {
    
        if let item = model as? NotificationItem {
            
            self.textLabel?.text = item.title
            var descAttrStr = NSMutableAttributedString(string: item.desc, attributes: [NSForegroundColorAttributeName: UIColor.ICTextLightGrayColor()])
            var dateAttrStr = NSMutableAttributedString(string: item.date, attributes: [NSForegroundColorAttributeName: UIColor.ICTextDarkGrayColor()])
            descAttrStr.appendAttributedString(NSMutableAttributedString(string:"\r"))
            descAttrStr.appendAttributedString(dateAttrStr)
            self.detailTextLabel?.numberOfLines = 0
            self.detailTextLabel?.attributedText = descAttrStr
            
       }
    }
}