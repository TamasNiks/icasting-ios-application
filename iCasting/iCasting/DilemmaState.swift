//
//  DilemmaState.swift
//  iCasting
//
//  Created by Tim van Steenoven on 08/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

protocol DilemmaState {
    init(view: DilemmaView)
    var decidedTitle: String? { get set }
    var buttonTitle: String? { get set }
    func setColor(color: UIColor?)
    func setView()
    func setExtendedButtonModeView()
    func startAnimation()
    func addTarget(target: AnyObject?, action: Selector, forControlEvents events: UIControlEvents)
    func addExtendedButtonTarget(target: AnyObject?, action: Selector, forControlEvents events: UIControlEvents)
}

class DilemmaLeftState: DilemmaState {
    
    let view: DilemmaView
    
    required init(view: DilemmaView) {
        self.view = view
    }
    
    var decidedTitle: String? {
        get {return view.leftViewLabel.text}
        set {view.leftViewLabel.text = newValue}
    }
    
    var buttonTitle: String? {
        get {return view.titleLeftButton}
        set {view.titleLeftButton = newValue}
    }
    
    func setColor(color: UIColor?) {
        view.leftButton.backgroundColor = color
    }
    
    func setView() {
        view.setLeftView()
    }
    
    func setExtendedButtonModeView() {
        view.extendedButtonModeLeft = true
        setView()
    }
    
    func startAnimation() {
        view.startLeftAnimation()
    }
    
    func addTarget(target: AnyObject?, action: Selector, forControlEvents events: UIControlEvents) {
        view.leftButton.addTarget(target, action: action, forControlEvents: events)
    }
    
    func addExtendedButtonTarget(target: AnyObject?, action: Selector, forControlEvents events: UIControlEvents) {
        
    }
    
}

class DilemmaRightState: DilemmaState {
    
    let view: DilemmaView
    
    required init(view: DilemmaView) {
        self.view = view
    }
    
    var decidedTitle: String? {
        set {view.titleRightView = newValue}
        get {return view.titleRightView}
    }
    
    var buttonTitle:String? {
        get {return view.titleRightButton}
        set {view.titleRightButton = newValue}
    }
    
    func setColor(color: UIColor?) {
        view.rightButton.backgroundColor = color
    }
    
    func setView() {
        view.setRightView()
    }
    
    func setExtendedButtonModeView() {
        view.extendedButtonModeRight = true
        setView()
    }
    
    func startAnimation() {
        view.startRightAnimation()
    }
    
    func addTarget(target: AnyObject?, action: Selector, forControlEvents events: UIControlEvents) {
        view.rightButton.addTarget(target, action: action, forControlEvents: events)
    }
    
    func addExtendedButtonTarget(target: AnyObject?, action: Selector, forControlEvents events: UIControlEvents) {
        view.rightViewButton.addTarget(target, action: action, forControlEvents: events)
    }
}