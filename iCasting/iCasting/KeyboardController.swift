//
//  KeyboardController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 17/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit


class KeyboardController: NSObject {
    
    var views: [UIView]
    var goingUpDivider: UInt = 1
    
    init(views: [UIView]) {
        self.views = views
    }
    
    func setObserver() {
    
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "handleKeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "handleKeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    
    func removeObserver() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func handleKeyboardWillShow(notification: NSNotification) {
        
        println("KeyboardController: keyboard will show")
        // Get the frame of the keyboard and place it in a CGRect
        let keyboardRectAsObject = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        var keyboardRect = CGRectZero
        keyboardRectAsObject.getValue(&keyboardRect)
        
        let offset = -keyboardRect.height / CGFloat(goingUpDivider)
        
        UIView.animateWithDuration(1, animations: { () -> Void in
    
            for view: UIView in self.views {
                println("view")
                view.transform = CGAffineTransformMakeTranslation(0, offset)
            }
        })
    }
    
    
    func handleKeyboardWillHide(notification: NSNotification) {
        
        println("KeyboardController: keyboard will hide")
        // Get the frame of the keyboard and place it in a CGRect
        let keyboardRectAsObject = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        var keyboardRect = CGRectZero
        keyboardRectAsObject.getValue(&keyboardRect)
        
        let offset = CGFloat(0)
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            
            for view: UIView in self.views {
                println("view")
                view.transform = CGAffineTransformMakeTranslation(0, offset)
            }
        })
        
    }

}