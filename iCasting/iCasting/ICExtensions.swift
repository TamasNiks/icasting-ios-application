//
//  ICExtensions.swift
//  iCasting
//
//  Created by T. van Steenoven on 21-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

extension UIImageView {
    
    public func makeRound(
        amount:CGFloat,
        borderWidth withBorderWidth: CGFloat? = 2.0,
        withBorderColor:UIColor = UIColor(white: 1.0, alpha: 1.0)) {

        self.layer.cornerRadius = amount
        self.clipsToBounds = true
        self.layer.frame = CGRectInset(self.layer.frame, 20, 20)
        
        if let bw = withBorderWidth {
            self.layer.borderColor = withBorderColor.CGColor
            self.layer.borderWidth = bw
        }

    }
    
}