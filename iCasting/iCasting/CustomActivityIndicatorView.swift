//
//  CustomActivityIndicatorView.swift
//  NavigationItemTest
//
//  Created by Tim van Steenoven on 13/07/15.
//  Copyright (c) 2015 Tim van Steenoven. All rights reserved.
//

import UIKit

class CustomActivityIndicatorView: UIView {
    
    static func activityViewWithLocalizedLoadingText() -> UIView {
        
        let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        ai.hidesWhenStopped = true
        ai.startAnimating()
        
        let label = UILabel(frame: CGRectMake(ai.bounds.width+5, 0, 0, 0))
        label.text = String(format: "%@...", NSLocalizedString("Loading", comment: ""))
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        
        let _view = CustomActivityIndicatorView(frame: CGRectMake(0, 0, label.bounds.width+ai.bounds.width, label.bounds.height))
        _view.addSubview(ai)
        _view.addSubview(label)
        
        return _view
    }
}
