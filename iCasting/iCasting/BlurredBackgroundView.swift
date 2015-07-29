//
//  BlurredBackgroundView.swift
//  iCasting
//
//  Created by Tim van Steenoven on 23/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class BlurredBackgroundView: UIView {

    let imageView: UIImageView
    let blurView: UIVisualEffectView
    
    override init(frame: CGRect) {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        blurView = UIVisualEffectView(effect: blurEffect)
        imageView = UIImageView(image: UIImage(named: "Default"))
        
        super.init(frame: frame)
        
        addSubview(imageView)
        addSubview(blurView)
    }
    
    convenience required init(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        blurView.frame = bounds
    }

}
