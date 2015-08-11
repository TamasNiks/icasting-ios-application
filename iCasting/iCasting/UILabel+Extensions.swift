//
//  UILabel+Extensions.swift
//  iCasting
//
//  Created by Tim van Steenoven on 10/08/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

extension UILabel {
    
    var textWithPrefixedCheckIcon: String {
        
        set {
            let checkIcon = String.fontAwesomeIconWithName(FontAwesome.Check)
            let _font = UIFont.fontAwesomeOfSize(self.font.pointSize)
            let _color = UIColor.ICGreenColor()
            var attributesForCheckIcon = [NSFontAttributeName : _font, NSForegroundColorAttributeName : _color]

            // Attributed strings
            let attrCheck = NSMutableAttributedString(string: checkIcon, attributes: attributesForCheckIcon)
            let attrValue = NSAttributedString(string: " "+newValue, attributes: [NSForegroundColorAttributeName : _color])
            
            attrCheck.appendAttributedString(attrValue)
            self.attributedText = attrCheck
        }
        
        get {
            return self.attributedText.string
        }
    }
}