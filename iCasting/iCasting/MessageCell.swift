//
//  MessageCell.swift
//  iCasting
//
//  Created by Tim van Steenoven on 06/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

struct MessageCellIdentifier {
    static let MessageCell: String = "messageCell"
    static let SystemMessageCell: String = "systemMessageCell"
}



class MessageCell: UITableViewCell {

    @IBOutlet weak var leftMessageLabel: UILabel!
    @IBOutlet weak var rightMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        leftMessageLabel.backgroundColor = UIColor.yellowColor()
        rightMessageLabel.backgroundColor = UIColor.redColor()
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        
        
        
        
    }

}


class SystemMessageCell: UITableViewCell {
    
    @IBOutlet weak var systemMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

