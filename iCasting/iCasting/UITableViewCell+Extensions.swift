//
//  UITableViewCell+Extensions.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    func calculateHeight() -> CGFloat {
        let size: CGSize = self.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height
    }
    
}