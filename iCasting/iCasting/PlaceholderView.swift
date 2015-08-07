//
//  Placeholder.swift
//  iCasting
//
//  Created by Tim van Steenoven on 21/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

class PlaceholderView: UIView {
    
    var image: UIImage? {
        
        // [START graphics context]
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0)
        
        self.layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let img: UIImage? = UIGraphicsGetImageFromCurrentImageContext()

        // [END graphics context]
        UIGraphicsEndImageContext()
        
        return img
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, rect)
        
        let currentContext = UIGraphicsGetCurrentContext()
        CGContextAddPath(currentContext, path)
        UIColor(white: 0.90, alpha: 1).setFill()
        CGContextDrawPath(currentContext, kCGPathFill)
    }
}



