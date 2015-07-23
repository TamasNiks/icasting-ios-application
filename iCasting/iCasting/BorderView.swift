//
//  BorderView.swift
//  iCasting
//
//  Created by Tim van Steenoven on 22/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class BorderView: UIView {

    var view: UIView!
    var round: Bool!
    
    typealias BorderClosure = (w: CGFloat) -> ()
    private var closure: BorderClosure?
    
    init(view: UIView, round: Bool, initialInset: CGFloat) {
        
        super.init(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
        
        self.view = view
        self.round = round
        
        if initialInset > 0 {
            self.view.frame = CGRectInset(self.view.frame, initialInset, initialInset)
        }
        
        self.addSubview(self.view)
    }
    
    func borderTest(#width: CGFloat, color: UIColor, insetForNext inset: CGFloat = 0) -> BorderView {
        
        self.frame = CGRectInset(view.frame, -inset, -inset)
        
        if round == true {
            view.layer.cornerRadius = view.frame.width / 2
            view.clipsToBounds = true
        }
        
        view.layer.borderWidth = width
        view.layer.borderColor = color.CGColor
        view.frame.origin = CGPointMake(inset, inset) //offset(dx: inset, dy: inset)
        
        return BorderView(view: self, round: round, initialInset: 0)
    }
    
    func border(#width: CGFloat, color: UIColor, margin: CGFloat = 0) -> BorderView {
        
        let totalWidth = width + margin
        
        // Call the closure if there is one, it will set the width of the previous border
        if let c = self.closure {
            c(w: totalWidth)
        }
        
        // If the initial view has been set to round true, create a circle
        if round == true {
            view.layer.cornerRadius = view.frame.width / 2
            view.clipsToBounds = true
        }
        
        // Set the border according to the parameters
        view.layer.borderWidth = width
        view.layer.borderColor = color.CGColor
        
        // Prepare the next view with a closure to call later on if the width is known
        let nextView = BorderView(view: self, round: round, initialInset: 0)
        nextView.closure = { (w: CGFloat) in
            
            self.frame = CGRectInset(self.view.frame, -w, -w)
            self.view.frame.origin = CGPointMake(w, w)
        }
        
        return nextView
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}