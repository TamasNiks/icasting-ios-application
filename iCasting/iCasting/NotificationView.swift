//
//  NotificationView.swift
//  iCasting
//
//  Created by Tim van Steenoven on 12/08/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class NotificationView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)

    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    

}
