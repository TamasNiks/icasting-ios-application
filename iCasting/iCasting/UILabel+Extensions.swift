//
//  UILabel+Extensions.swift
//  iCasting
//
//  Created by Tim van Steenoven on 10/08/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

extension UILabel {
    
    
    var setPrefixedIcon: FontAwesome? {
        
        set {

            if let newValue = newValue {
                let icon = String.fontAwesomeIconWithName(newValue)
                let _font = UIFont.fontAwesomeOfSize(self.font.pointSize)
                let _color = self.textColor
                var attributesForCheckIcon = [NSFontAttributeName : _font, NSForegroundColorAttributeName : _color]
                
                // Attributed strings
                let attrCheck = NSMutableAttributedString(string: icon, attributes: attributesForCheckIcon)
                let attrValue = NSAttributedString(string: " "+(self.text ?? ""), attributes: [NSForegroundColorAttributeName : _color])
                
                attrCheck.appendAttributedString(attrValue)
                self.attributedText = attrCheck
            } else {
                self.attributedText = nil
            }

        }
        
        get {
            return nil
        }
        
    }
    
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