//
//  UIViewController+Extensions.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func startAnimatingLoaderTitleView() {
        if let ng = self.navigationController {
            self.navigationItem.titleView = CustomActivityIndicatorView.activityViewWithLocalizedLoadingText()
        }
    }
    
    func stopAnimatingLoaderTitleView() {
        if let ng = self.navigationController {
            self.navigationItem.titleView = nil
        }
    }
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        // bail if the current state matches the desired state
        //if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        var offsetY = (visible ? -height! : height)
        println ("offsetY = \(offsetY)")
        
        // zero duration means no animation
        let duration:NSTimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        //        if frame != nil {
        //            UIView.animateWithDuration(duration) {
        //                self.tabBarController?.tabBar.frame = CGRectOffset(frame!, 0, offsetY!)
        //                return
        //            }
        //        }
        
        // animate tabBar
        if frame != nil {
            UIView.animateWithDuration(duration) {
                self.tabBarController?.tabBar.frame = CGRectOffset(frame!, 0, offsetY!)
                self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height + offsetY!)
                self.view.setNeedsDisplay()
                self.view.layoutIfNeeded()
                return
            }
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return self.tabBarController?.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame)
    }
    
    // Call the function from tap gesture recognizer added to your view (or button)
    //
    //    @IBAction func tapped(sender: AnyObject) {
    //        setTabBarVisible(!tabBarIsVisible(), animated: true)
    //    }
}