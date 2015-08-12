//
//  MatchDefaultCell.swift
//  iCasting
//
//  Created by Tim van Steenoven on 16/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class MatchDefaultCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


extension MatchDefaultCell {
    
    func configureCell(#item: [String:String]) {
        
        var key: String = item.keys.first!
        var value: String = item[key] ?? "-"
        
        textLabel?.text = NSLocalizedString(key, comment: "The text labels from a row, gotten from the JSON keys")
        detailTextLabel?.text = value
    }

}