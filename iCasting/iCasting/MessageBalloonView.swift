//
//  MessageBalloon.swift
//  VariableCellHeightTestProject
//
//  Created by Tim van Steenoven on 04/06/15.
//  Copyright (c) 2015 Tim van Steenoven. All rights reserved.
//

import UIKit

class MessageBalloonView: UIView {

    enum Position: Int {
        case Left, Right
    }
    
    let RECT_INSET: CGFloat = 10 // Lower is more room between border and text
    let LINE_WIDTH: CGFloat = 1
    let LINE_COLOR: UIColor = UIColor(white: 0.8, alpha: 1)
    let FILL_COLOR: UIColor = UIColor(white: 0.98, alpha: 1)
    let CORNER_RADIUS: CGFloat = 8
    let HORIZONTAL_HOOK_POS: CGFloat = 40 // Less is more to the right
    let HOOK_WIDTH: CGFloat = 16
    
    
    var _position: Position = Position.Left
    
    @IBInspectable var position: Int {
        
        get {
            return self._position.rawValue
        }
        set {
            //println("position: \(newValue)")
            if let pos = Position(rawValue: newValue) {
                self._position = pos
            }
        }
    }
    
    init(frame: CGRect, position: Position) {

        self._position = position
        
        super.init(frame: frame)
        self.opaque = false
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func createHookPath(rect: CGRect) -> CGMutablePath {
        
        let path = CGPathCreateMutable()

        var horx = HORIZONTAL_HOOK_POS

        var x: CGFloat = 0
        
        switch self._position {
        case .Right:
            x = rect.width-(horx-HOOK_WIDTH)
        case .Left:
            x = horx
        }
        
        CGPathMoveToPoint(path,     nil, x                  , rect.height-RECT_INSET-0.75)
        CGPathAddLineToPoint(path,  nil, x-HOOK_WIDTH/2     , rect.height-3)
        CGPathAddLineToPoint(path,  nil, x-HOOK_WIDTH       , rect.height-RECT_INSET-0.75)
        
        return path
    }

    func createRoundedRectPath(rect: CGRect) -> CGMutablePath {
        
        let path = CGPathCreateMutable()
        
        CGPathAddRoundedRect(path, nil, rect, CORNER_RADIUS, CORNER_RADIUS)
        
        return path
    }
    

    override func drawRect(rect: CGRect) {
        // Drawing code
        
        var r = rect.rectByInsetting(dx: RECT_INSET, dy: RECT_INSET) //rectByOffsetting(dx: 50, dy: 50)

        let roundedRectPath = createRoundedRectPath(r)
        let hookPath = createHookPath(rect)

        
        // Current context

        switch self._position {
        case .Right:
            UIColor.whiteColor().setFill()
        case .Left:
            FILL_COLOR.setFill()
        }
        
        
        LINE_COLOR.setStroke()
        
        let currentContext = UIGraphicsGetCurrentContext()
        
        CGContextSetLineWidth(currentContext, LINE_WIDTH)
        CGContextSetLineCap(currentContext, kCGLineCapButt)
        
        CGContextAddPath(currentContext, roundedRectPath)
        CGContextDrawPath(currentContext, kCGPathFillStroke)
        
        CGContextAddPath(currentContext, hookPath)
        CGContextDrawPath(currentContext, kCGPathFillStroke)
        
        
        
    }
    
}
