//
//  TextInputController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 16/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class TextInputViewControllerTest: UIViewController {
    
    @IBOutlet weak var inputToolbar: JSQMessagesInputToolbar!
    @IBOutlet weak var toolbarHeightConstraint: NSLayoutConstraint!
    
    // Textinput vars
    var textView: UITextView?
    var isObserving: Bool = false
    static var kJSQMessagesKeyValueObservingContext = 0
    let topContentAdditionalInset: CGFloat = 0
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &TextInputViewControllerTest.kJSQMessagesKeyValueObservingContext {
            
            if (object as! NSObject) == self.inputToolbar.contentView.textView && keyPath == NSStringFromSelector(Selector("contentSize")) {
                println("observe")
                println(change[NSKeyValueChangeOldKey]!)
                println(change[NSKeyValueChangeNewKey]!)
                
                let oldContentSize: CGSize = (change[NSKeyValueChangeOldKey])!.CGSizeValue()
                let newContentSize: CGSize = (change[NSKeyValueChangeNewKey])!.CGSizeValue()
                
                var dy: CGFloat = newContentSize.height - oldContentSize.height
                println(newContentSize.height)
                println(oldContentSize.height)
                println(dy)
                
                self.adjustInputToolbarForComposerTextViewContentSizeChange(dy)
                //self.updateCollectionViewInsets()
                //            if (self.automaticallyScrollsToMostRecentMessage) {
                //                [self scrollToBottomAnimated:NO];
                //            }
                //}
            }
            
        }
    }
    
    
    // Methods to regulate the height of the toolbar
    
    func inputToolbarHasReachedMaximumHeight() -> Bool {
        
        return CGRectGetMinY(self.inputToolbar.frame) == (self.topLayoutGuide.length + self.topContentAdditionalInset)
    }
    
    func adjustInputToolbarForComposerTextViewContentSizeChange(dy: CGFloat) {
        
        var dy2 = dy
        
        let contentSizeIsIncreasing: Bool = (dy2 > 0)
        
        if inputToolbarHasReachedMaximumHeight() {
            
            let contentOffsetIsPositive: Bool = (self.inputToolbar.contentView.textView.contentOffset.y > 0)
            
            if (contentSizeIsIncreasing || contentOffsetIsPositive) {
                self.scrollComposerTextViewToBottomAnimated(true)
                return
            }
            
        }
        
        let toolbarOriginY: CGFloat = CGRectGetMinY(self.inputToolbar.frame)
        let newToolbarOriginY: CGFloat = toolbarOriginY - dy2
        
        //  attempted to increase origin.Y above topLayoutGuide
        if newToolbarOriginY <= self.topLayoutGuide.length + self.topContentAdditionalInset {
            
            dy2 = toolbarOriginY - (self.topLayoutGuide.length + self.topContentAdditionalInset)
            self.scrollComposerTextViewToBottomAnimated(true)
        }
        
        self.adjustInputToolbarHeightConstraintByDelta(dy2)
        
        //self.updateKeyboardTriggerPoint()
        
        if (dy2 < 0) {
            self.scrollComposerTextViewToBottomAnimated(false)
        }
        
    }
    
    
    func adjustInputToolbarHeightConstraintByDelta(dy: CGFloat) {
        
        let proposedHeight: CGFloat = self.toolbarHeightConstraint.constant + dy
        
        var finalHeight: CGFloat = max(proposedHeight, self.inputToolbar.preferredDefaultHeight)
        
        if self.inputToolbar.maximumHeight != UInt(Foundation.NSNotFound) {
            
            finalHeight = min(finalHeight, CGFloat(self.inputToolbar.maximumHeight))
        }
        
        if (self.toolbarHeightConstraint.constant != finalHeight) {
            
            self.toolbarHeightConstraint.constant = finalHeight
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
        }
    }
    
    
    func scrollComposerTextViewToBottomAnimated(animated: Bool) {
        
        let textView: UITextView = self.inputToolbar.contentView.textView
        let contentOffsetToShowLastLine: CGPoint = CGPointMake(0.0, textView.contentSize.height - CGRectGetHeight(textView.bounds))
        
        if (!animated) {
            textView.contentOffset = contentOffsetToShowLastLine
            return
        }
        
        let duration: NSTimeInterval = 0.01
        let delay: NSTimeInterval = 0.01
        
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            textView.contentOffset = contentOffsetToShowLastLine;
            }, completion: nil)
        
    }
    
}