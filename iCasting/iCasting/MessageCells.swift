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


//**********************************************************


class MessageCell: UITableViewCell {

    @IBOutlet weak var leftMessageLabel: UILabel!
    @IBOutlet weak var rightMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        leftMessageLabel.backgroundColor = UIColor.greenColor()
        rightMessageLabel.backgroundColor = UIColor.redColor()
    }

}


class MessageSystemCell: UITableViewCell {
    
    @IBOutlet weak var systemMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}


class MessageUnacceptedCell: UITableViewCell {
    
    @IBOutlet weak var systemMessageLabel: UILabel!
    @IBOutlet weak var unacceptedPointsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}


class MessageOfferCell: UITableViewCell {
    
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
            if let nv = newValue {
                
                if nv == true {
                    dilemmaView.startAcceptAnimation()
                } else {
                    dilemmaView.startRejectAnimation()
                }
            } else {
                dilemmaView.reinitialize()
                //dilemmaView.layoutIfNeeded()
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
                self.accepted = true
            })
        }
    }
    
    func onRejectButtonPress(event: UIButton) {
        
        if let ip = indexPath {
            delegate?.offerCell(self, didPressButtonWithOfferStatus: OfferStatus.Reject, forIndexPath: ip, startAnimation: { () -> () in
                self.accepted = false
            })
        }
    }
}
