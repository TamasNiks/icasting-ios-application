//
//  MessageCells.swift
//  iCasting
//
//  Created by Tim van Steenoven on 06/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit


enum OfferStatus {
    case Accept, Reject
}


protocol MessageOfferCellDelegate {
    func offerCell(
        cell: MessageOfferCell,
        didPressButtonWithOfferStatus offerStatus: OfferStatus,
        forIndexPath indexPath: NSIndexPath,
        startAnimation: ()->())
}


struct MessageCellIdentifier {
    static let MessageCell: String = "messageCell"
    static let SystemMessageCell: String = "systemMessageCell"
}



// TEST

protocol CellVisitorAcceptProtocol {

    func accept(configurator: MessageCellCongifuratorVisitors)
    
}



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





class MessageSystemCell: UITableViewCell, CellVisitorAcceptProtocol {
    
    @IBOutlet weak var systemMessageLabel: UILabel!
    
    func accept(configurator: MessageCellCongifuratorVisitors) {
        configurator.visit(self)
    }
}





class MessageUnacceptedCell: UITableViewCell, CellVisitorAcceptProtocol {
    
    @IBOutlet weak var systemMessageLabel: UILabel!
    @IBOutlet weak var unacceptedPointsLabel: UILabel!
    
    func accept(configurator: MessageCellCongifuratorVisitors) {
        configurator.visit(self)
    }
}





class MessageOfferCell: UITableViewCell, CellVisitorAcceptProtocol {
    
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var dilemmaView: DilemmaView!
    
    var indexPath: NSIndexPath?
    
    var delegate: MessageOfferCellDelegate? {
        didSet {
            setup()
        }
    }
    
    var accepted: Bool? {
        
        willSet {
            dilemmaView.reinitialize()
            if let nv = newValue {
                if nv == true {
                    dilemmaView.setLeftView()
                } else {
                    dilemmaView.setRightView()
                }
            }
        }
    }
    
    private func setup() {
        
        dilemmaView.leftButton.addTarget(self, action: "onAcceptButtonPress:", forControlEvents: UIControlEvents.TouchUpInside)
        dilemmaView.rightButton.addTarget(self, action: "onRejectButtonPress:", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func onAcceptButtonPress(event: UIButton) {
        
        if let ip = indexPath {
            delegate?.offerCell(self, didPressButtonWithOfferStatus: OfferStatus.Accept, forIndexPath: ip, startAnimation: { () -> () in
                self.dilemmaView.startLeftAnimation()
            })
        }
    }
    
    func onRejectButtonPress(event: UIButton) {
        
        if let ip = indexPath {
            delegate?.offerCell(self, didPressButtonWithOfferStatus: OfferStatus.Reject, forIndexPath: ip, startAnimation: { () -> () in
                self.dilemmaView.startRightAnimation()
            })
        }
    }
    
    func accept(configurator: MessageCellCongifuratorVisitors) {
        configurator.visit(self)
    }
}
