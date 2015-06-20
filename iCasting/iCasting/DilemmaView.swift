//
//  DilemmaView.swift
//  iCasting
//
//  Created by Tim van Steenoven on 01/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class DilemmaView: UIView {

    let nibName: String = "DilemmaView"
    
    let ANIMATION_DURATION: NSTimeInterval = 0.7
    
    var leftView: UIView!
    var rightView: UIView!
    var buttonView: UIView!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftViewLabel: UILabel!
    @IBOutlet weak var rightViewLabel: UILabel!
    
    
    @IBInspectable var titleLeftButton: String? {
        get {
            return leftButton.titleForState(UIControlState.Normal)
        }
        set {
            leftButton.setTitle(newValue, forState: UIControlState.Normal)
        }
    }

    @IBInspectable var titleRightButton: String? {
        get {
            return rightButton.titleForState(UIControlState.Normal)
        }
        set {
            rightButton.setTitle(newValue, forState: UIControlState.Normal)
        }
    }

    @IBInspectable var titleLeftView: String? {
        get {
            return leftViewLabel.text
        }
        set {
            leftViewLabel.text = newValue
        }
    }
    
    @IBInspectable var titleRightView: String? {
        get {
            return rightViewLabel.text
        }
        set {
            rightViewLabel.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        clipsToBounds = true
        
        let views: [UIView] = loadViewsFromNib()
        
        buttonView = views[0]
        rightView = views[1]
        leftView = views[2]
        
        configureView(buttonView)
        configureView(rightView)
        configureView(leftView)
        
        addSubview(buttonView)
        addSubview(rightView)
        addSubview(leftView)
        
        startSettingsRightView(rightView)
        startSettingsLeftView(leftView)

    }
    
    func reinitialize() {
        //println("Will reinitialize")
        startSettingsMiddleView(buttonView)
        startSettingsLeftView(leftView)
        startSettingsRightView(rightView)
    }
    
    
    func startRightAnimation() {
        
        UIView.animateWithDuration(
            ANIMATION_DURATION,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in

            self.setRightView()
            }, completion: nil)
    }
    
    func startLeftAnimation() {
        
        UIView.animateWithDuration(
            ANIMATION_DURATION,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
            
            self.setLeftView()
            }, completion: nil)
    }
    
    
    func setLeftView() {
        self.finalSettingsView(self.leftView)
        self.finalSettingsMiddleViewForLeft(self.buttonView)
    }
    
    
    func setRightView() {
        self.finalSettingsView(self.rightView)
        self.finalSettingsMiddleViewForRight(self.buttonView)
    }
    
    
    private func startSettingsLeftView(view: UIView) {
        view.alpha = 0
        view.transform = CGAffineTransformMakeTranslation(-view.bounds.size.width / 2, 0)
    }
    
    private func startSettingsRightView(view: UIView) {
        view.alpha = 0
        view.transform = CGAffineTransformMakeTranslation(view.bounds.size.width / 2, 0)
    }

    private func startSettingsMiddleView(view: UIView) {
        view.alpha = 1
        view.transform = CGAffineTransformMakeTranslation(0, 0)
    }
    
    private func finalSettingsView(view: UIView) {
        view.alpha = 0.60
        view.transform = CGAffineTransformMakeTranslation(0, 0)
    }
    
    private func finalSettingsMiddleViewForLeft(view: UIView) {
        view.alpha = 0
        view.transform = CGAffineTransformMakeTranslation(view.bounds.size.width * 2, 0)
    }
    
    private func finalSettingsMiddleViewForRight(view: UIView) {
        view.alpha = 0
        view.transform = CGAffineTransformMakeTranslation(-view.bounds.size.width * 2, 0)
    }
    
    
    private func configureView(view: UIView) {
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
    }
    
    private func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    private func loadViewsFromNib() -> [UIView] {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiateWithOwner(self, options: nil).map { $0 as! UIView }
    }


}
