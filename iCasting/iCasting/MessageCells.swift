//
//  MessageCells.swift
//  iCasting
//
//  Created by Tim van Steenoven on 06/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit


enum DilemmaStatus {
    case Accept, Reject
}


protocol DilemmaCellDelegate {
    func offerCell(
        cell: UITableViewCell,
        didPressButtonWithOfferStatus dilemmaStatus: DilemmaStatus,
        forIndexPath indexPath: NSIndexPath,
        startAnimation: ()->())
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





class DilemmaCell: UITableViewCell {

    @IBOutlet weak var dilemmaView: DilemmaView!
    
    var indexPath: NSIndexPath?
    
    var delegate: DilemmaCellDelegate? {
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
    
    var enabled: Bool = true {
        
        willSet {
            if newValue == true {
                dilemmaView.enableButtons()
            } else {
                dilemmaView.disableButtons()
            }
        }
    }
    
    var rejectedTitle: String? {
        set { dilemmaView.rightViewLabel.text = newValue }
        get { return dilemmaView.rightViewLabel.text }
    }
    
    var acceptedTitle: String? {
        set { dilemmaView.leftViewLabel.text = newValue }
        get { return dilemmaView.leftViewLabel.text }
    }
    
    // iOS 8
//    override func prepareForReuse() {
//        self.accepted = nil
//        self.enabled = true
//    }
    
    private func setup() {
        
        dilemmaView.leftButton.addTarget(self, action: "onAcceptButtonPress:", forControlEvents: UIControlEvents.TouchUpInside)
        dilemmaView.rightButton.addTarget(self, action: "onRejectButtonPress:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func onAcceptButtonPress(event: UIButton) {
        
        if let ip = indexPath {
            delegate?.offerCell(self, didPressButtonWithOfferStatus: DilemmaStatus.Accept, forIndexPath: ip, startAnimation: { () -> () in
                self.dilemmaView.startLeftAnimation()
            })
        }
    }
    
    func onRejectButtonPress(event: UIButton) {
        
        if let ip = indexPath {
            delegate?.offerCell(self, didPressButtonWithOfferStatus: DilemmaStatus.Reject, forIndexPath: ip, startAnimation: { () -> () in
                self.dilemmaView.startRightAnimation()
            })
        }
    }
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


class MessageRenegotiationRequestCell: DilemmaCell {
    
    @IBOutlet weak var title: UILabel!
}



