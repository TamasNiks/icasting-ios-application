//
//  UIImageView+Extensions.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func makeRound(
        amount:CGFloat,
        withBorderWidth borderWidth: CGFloat? = 2.0,
        andBorderColor borderColor:UIColor = UIColor(white: 1.0, alpha: 1.0)) {
            
            self.layer.cornerRadius = amount
            self.clipsToBounds = true
            
            if let bw = borderWidth {
                self.addBorder(borderWidth: bw, color: borderColor)
            }
    }
    
    func addBorder(borderWidth: CGFloat = 1.0, color:UIColor = UIColor(white: 1.0, alpha: 1.0)) {
        
        self.layer.borderColor = color.CGColor
        self.layer.borderWidth = borderWidth
    }
}