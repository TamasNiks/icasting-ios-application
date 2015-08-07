//
//  MessageCells.swift
//  iCasting
//
//  Created by Tim van Steenoven on 06/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit


//**********************************************************


class MessageCell: UITableViewCell, CellVisitorAcceptProtocol {

    @IBOutlet weak var leftMessageLabel: UILabel!
    @IBOutlet weak var rightMessageLabel: UILabel!
    @IBOutlet weak var leftMessageView: UIView!
    @IBOutlet weak var rightMessageView: UIView!
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        leftMessageLabel.backgroundColor = UIColor.greenColor()
//        rightMessageLabel.backgroundColor = UIColor.redColor()
//    }
    
    // Because a cell will be reused, it is important to update the custom drawing of the subviews as well, because a different already drawn view could be used instead, this could lead to drawings which are stretched.
    override func prepareForReuse() {
        super.prepareForReuse()
        leftMessageView.setNeedsDisplay()
        rightMessageView.setNeedsDisplay()
    }

    func showOutgoingMessageView() {
        self.rightMessageView.hidden = false
        self.leftMessageView.hidden = true
    }
    
    func showIncommingMessageView() {
        self.leftMessageView.hidden = false
        self.rightMessageView.hidden = true
    }
 
    func accept(configurator: MessageCellCongifuratorVisitors) {
        configurator.visit(self)
    }
    
}


class MessageSystemCell: UITableViewCell {
    
    @IBOutlet weak var systemMessageLabel: UILabel!
}


class MessageUnacceptedCell: UITableViewCell {
    
    @IBOutlet weak var systemMessageLabel: UILabel!
    @IBOutlet weak var unacceptedPointsLabel: UILabel!
}


class MessageOfferCell: DilemmaCell {

    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
}


class MessageContractOfferCell: DilemmaCell {
    
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var subdescription: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}


class MessageDefaultDecisionCell: DilemmaCell {

    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var title: UILabel!
}





