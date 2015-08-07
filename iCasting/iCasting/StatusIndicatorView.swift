//
//  StatusIndicatorView.swift
//  iCasting
//
//  Created by Tim van Steenoven on 22/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class StatusIndicatorView: UIView {
    
    var circle: UIView?
    
    init(frame: CGRect, status: FilterStatusFields) {
        
        super.init(frame: frame)
        let color = MatchStatusColor.color(status)
        createCircle(color)
    }

    init(frame: CGRect, color: UIColor) {
        
        super.init(frame: frame)
        createCircle(color)
    }
    
    func startAnimating() {
        
        fadeInOut()
    }
    
    private func fadeInOut() {

        UIView.animateWithDuration(0.50, animations: { () -> Void in
            let a = self.circle?.alpha
            self.circle?.alpha = a == 1 ? 0.25 : 1
        }) { (bool) -> Void in
            self.fadeInOut()
        }
    }

    private func createCircle(color: UIColor?) {
        
        let circle = CircleView(frame: frame)
        circle.color = color
        self.backgroundColor = UIColor.whiteColor()
        self.addSubview(circle)
        self.circle = circle
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}





class CircleView: UIView {

    var color: UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.opaque = false
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        let path = CGPathCreateMutable()
        CGPathAddEllipseInRect(path, nil, rect)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextAddPath(context, path)
    
        color?.setFill()
        
        CGContextDrawPath(context, kCGPathFill)
    }

}
