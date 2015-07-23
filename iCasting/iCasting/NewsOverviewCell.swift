//
//  NewsOverviewCell.swift
//  iCasting
//
//  Created by Tim van Steenoven on 21/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class NewsOverviewCell: UITableViewCell {

    let fadeInAnimation: NSTimeInterval = 0.75
    
    var _image: UIImage? {
        willSet {
            
            super.imageView?.image = newValue
            super.imageView?.tag = 1
            super.imageView?.alpha = 0
            super.setNeedsLayout()
            
            UIView.animateWithDuration(fadeInAnimation, animations: { () -> Void in
                
                super.imageView?.alpha = 1
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        super.imageView?.bounds = CGRectMake(0, 0, 55, 55)
    }
    
    // iOS 8
    override func prepareForReuse() {
        
        if let img = _image {
            super.imageView?.image = img
        }
        
    }

}
