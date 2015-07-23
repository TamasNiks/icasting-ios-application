//
//  CircleView.swift
//  iCasting
//
//  Created by Tim van Steenoven on 22/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit


class MatchStatusColor {
    
    static func color(status: FilterStatusFields) -> UIColor? {
        
        switch status {
         
        case .Pending:
            return UIColor.lightGrayColor()
        case .TalentAccepted:
            return UIColor.orangeColor()
        case .Negotiations:
            return UIColor(red: 123/255, green: 205/255, blue: 105/255, alpha: 1)
        case .Closed:
            return UIColor.redColor()
        default:
            return nil
        }
    }
}


class StatusIndicator: UIView {
    
    init(frame: CGRect, status: FilterStatusFields) {
        
        super.init(frame: frame)
        let color = MatchStatusColor.color(status)
        createCircle(color)
    }

    init(frame: CGRect, color: UIColor) {
        
        super.init(frame: frame)
        createCircle(color)
    }
    
    private func createCircle(color: UIColor?) {
        
        let circle = CircleView(frame: frame)
        circle.color = color
        self.backgroundColor = UIColor.whiteColor()
        self.addSubview(circle)
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
