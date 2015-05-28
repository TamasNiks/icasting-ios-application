//
//  MatchSummaryCell.swift
//  iCasting
//
//  Created by Tim van Steenoven on 28/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class MatchSummaryCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension MatchSummaryCell {
    
    func configureCell(item: MatchDetailType) {
        
        self.textLabel?.text = item.general[.JobTitle]!
        self.detailTextLabel?.text = item.general[.JobDescription]!
    }
    
    
}
