//
//  NegotiationDetailTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 06/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit


// Bind the TextType of the cells with the CellIdentifiers

enum CellIdentifier: String {
    case
    MessageCell = "messageCell",
    UnacceptedCell = "unacceptedMessageCell",
    GeneralSystemMessageCell = "generalSystemMessageCell",
    OfferMessageCell = "offerMessageCell"
    
    static func fromTextType(type: TextType) -> CellIdentifier? {
        
        let ids = [
            TextType.Text                       :   CellIdentifier.MessageCell,
            TextType.SystemText                 :   CellIdentifier.GeneralSystemMessageCell,
            TextType.SystemContractUnaccepted   :   CellIdentifier.UnacceptedCell,
            TextType.Offer                      :   CellIdentifier.OfferMessageCell
        ]
        
        return ids[type]
    }
    
}


class NegotiationDetailTableViewController: UITableViewController, UIScrollViewDelegate, UITextFieldDelegate, MessageOfferCellDelegate {
    
    
    var matchID: String?
    var conversation: Conversation?
    var messages: [Message] = [Message]()
    
    var sizingCellProvider: SizingCellProvider?
    var cellReuser: NegotiationDetailCellConfigurationFactory?
    
    
    func initializeFooterView() {
        
//        let inputField: UITextField = UITextField(frame: CGRectMake(0, 0, 0, 50))
//        inputField.backgroundColor = UIColor.redColor()
//        
//        self.tableView.tableFooterView = inputField
//        self.tableView.tableFooterView?.hidden = true
    }
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
//        var x: CGFloat = 0
//        var y = (self.tableView?.contentOffset.y)! + 40
//        self.tableView.tableFooterView?.transform = CGAffineTransformMakeTranslation(x, y)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeFooterView()
        self.sizingCellProvider = SizingCellProvider(tableView: tableView)
        self.cellReuser = NegotiationDetailCellConfigurationFactory(tableView: tableView)
    
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let ID = matchID {
            conversation = Conversation(matchID: ID)
        }
        
        // Get all the current messages available from the server
        conversation?.get() { failure in
            
            self.messages = self.conversation!.messages
            
            println("ConversationTableViewController: request finnished")
            self.tableView.reloadData()
            
            let index: Int = self.conversation!.messages.endIndex - 1
            self.tableView.scrollToRowAtIndexPath(
                NSIndexPath(forRow: index, inSection: 0),
                atScrollPosition: UITableViewScrollPosition.Bottom,
                animated: true)
            //self.tableView.tableFooterView?.hidden = false
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let c = self.conversation?.messages.count {
            return c
        }
        return 0
    }

    
    func getModelForIndexPath(indexPath: NSIndexPath) -> Message {
        
        return messages[indexPath.row]
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        

        if let cell = getAndConfigCell(indexPath) {
            
            return cell
            
        } else {
            
            var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(
                CellIdentifier.MessageCell.rawValue,
                forIndexPath: indexPath) as! UITableViewCell
            
            return cell
        }
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return getHeightForCell(indexPath)
    }
    
    
    func getAndConfigCell(indexPath: NSIndexPath) -> UITableViewCell? {
        
        let message: Message = getModelForIndexPath(indexPath)
        
        if let identifier = CellIdentifier.fromTextType(message.type) {
            
            var cell = cellReuser!.reuseCell(identifier, indexPath: indexPath)
            var configurator = cellReuser!.getConfigurator()
            
            if identifier == CellIdentifier.GeneralSystemMessageCell {
                
                configurator?.configureCell(data: [.Description:message.body])
            }
            
            if identifier == CellIdentifier.MessageCell {
                
                configurator?.configureCell(data: [.Model:message as Any])
            }
            
            if identifier == CellIdentifier.UnacceptedCell {
                
                configurator?.configureCell(data: [.Model:message as Any])
            }
            
            if identifier == CellIdentifier.OfferMessageCell {
                
                var data = [
                    CellKey.Model       :   message as Any,
                    CellKey.IndexPath   :   indexPath,
                    CellKey.Delegate    :   self]
                
                configurator?.configureCell(data: data)
            }
            
            return cell
        }
        
        return nil
    }

    
    func getHeightForCell(indexPath: NSIndexPath) -> CGFloat {
        
        let message: Message = messages[indexPath.row]
        let identifier = CellIdentifier.fromTextType(message.type)
        var height: CGFloat
        
        if identifier == CellIdentifier.OfferMessageCell {
            
            height = sizingCellProvider!.heightForCustomCell(fromIdentifier: CellIdentifier.OfferMessageCell, calculatorType:.AutoLayout) { (cell) -> () in
                
                OfferMessageCellConfigurator(cell: cell).configureCellText(data: [.Model:message as Any])
            }
        }
        else if identifier == CellIdentifier.UnacceptedCell {
            
            height = sizingCellProvider!.heightForCustomCell(fromIdentifier: CellIdentifier.UnacceptedCell, calculatorType:.AutoLayout) { (cell) -> () in
                
                UnacceptedListMessageCellConfigurator(cell: cell).configureCellText(data: [.Model:message as Any])
            }
            
            println("height for unaccepted: \(height) ")
            //height = 150
            
            
        }
        else {
            
            height = 60
        }
        
        return height
    }
    
    
    // Offer cell delegate
    
    func offerCell(
        cell: MessageOfferCell,
        didPressButtonWithOfferStatus offerStatus: OfferStatus,
        forIndexPath indexPath: NSIndexPath,
        startAnimation: () -> ()) {
        
        if offerStatus == OfferStatus.Accept {
            
            cell.accepted = true
        }
        
        if offerStatus == OfferStatus.Reject {
            
            cell.accepted = false
        }
        
        // if everything is complete, do the animation:
        //startAnimation()
    }

}
