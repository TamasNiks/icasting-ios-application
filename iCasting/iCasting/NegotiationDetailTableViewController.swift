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
    
    var messages: [Message] {
        return conversation?.messages ?? [Message]()
    }
    
    var sizingCellProvider: SizingCellProvider?
    var cellReuser: NegotiationDetailCellConfigurationFactory?
    
    var newMessagesListContext: Int = 0
    var userJoinedOrLeft: Int = 0
    var userAuthenticate: Int = 0
    
    struct ObservableConversation {
        static var messageList: String = "messageList.list"
        static var incommingUser: String = "incommingUser"
        static var authenticated: String = "authenticated"
    }


    
    // MARK: - Viewcontroller Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareViewController()
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.initializeModel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        removeObservers()
    }
    
    
    
    // MARK: - startup functions
    
    private func prepareViewController() {
        
        self.sizingCellProvider = SizingCellProvider(tableView: tableView)
        self.cellReuser = NegotiationDetailCellConfigurationFactory(tableView: tableView)
    }
    
    private func initializeModel() {
        
        if let ID = matchID {
            conversation = Conversation(matchID: ID)
        }
        
        // Get all the current messages available from the server
        
        conversation?.get() { failure in
            
            //self.messages = self.conversation!.messages
            
            if self.messages.isEmpty == false {
                
                println("ConversationTableViewController: request finnished")
                self.tableView.reloadData()
                
                self.scrollToBottom()
                //self.tableView.tableFooterView?.hidden = false
                self.addObservers()
            }
        }
    }
    

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.messages.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        

        if let cell = getAndConfigCell(indexPath) {
        //if let cell = getAndConfigCellWithVisitor(indexPath) {
            
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
    
    
    
    // MARK: - Data source helper methods
    
    func getModelForIndexPath(indexPath: NSIndexPath) -> Message {
        
        return messages[indexPath.row]
    }
    
    
    
    func getAndConfigCellWithVisitor(indexPath: NSIndexPath) -> UITableViewCell? {
     
        let message: Message = getModelForIndexPath(indexPath)
        
        if let identifier = CellIdentifier.fromTextType(message.type) {
            
            var cell = cellReuser!.reuseCell(identifier, indexPath: indexPath)
            
            if identifier == CellIdentifier.GeneralSystemMessageCell {
               
                var visitor = ConcreteMessageCellCongifuratorVisitors(data: [.Description:message.body])
                (cell as! MessageSystemCell).accept(visitor)
            }
            
            if identifier == CellIdentifier.MessageCell {
                
                var visitor = ConcreteMessageCellCongifuratorVisitors(data: [.Model:message as Any])
                (cell as! MessageCell).accept(visitor)
            }
            
            if identifier == CellIdentifier.UnacceptedCell {
                
                var visitor = ConcreteMessageCellCongifuratorVisitors(data: [.Model:message as Any])
                (cell as! MessageUnacceptedCell).accept(visitor)
                
            }
            
            if identifier == CellIdentifier.OfferMessageCell {
                
                var data = [
                    CellKey.Model       :   message as Any,
                    CellKey.IndexPath   :   indexPath,
                    CellKey.Delegate    :   self]
                
                var visitor = ConcreteMessageCellCongifuratorVisitors(data: data)
                (cell as! MessageOfferCell).accept(visitor)
            }
            
            return cell
        }
        return nil
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
        
        let message: Message = getModelForIndexPath(indexPath) //messages[indexPath.row]
        let identifier = CellIdentifier.fromTextType(message.type)
        var height: CGFloat = 60
        
        if identifier == CellIdentifier.MessageCell {
            
            height = sizingCellProvider!.heightForCustomCell(fromIdentifier: CellIdentifier.MessageCell, calculatorType:.AutoLayout) { (cell) -> () in
                
                MessageCellConfigurator(cell: cell).configureCellText(data: [.Model:message as Any])
            }
            
        }
        
        if identifier == CellIdentifier.UnacceptedCell {
            
            height = sizingCellProvider!.heightForCustomCell(fromIdentifier: CellIdentifier.UnacceptedCell, calculatorType:.AutoLayout) { (cell) -> () in
                
                UnacceptedListMessageCellConfigurator(cell: cell).configureCellText(data: [.Model:message as Any])
            }
            
        }
        
        if identifier == CellIdentifier.OfferMessageCell {
            
            height = sizingCellProvider!.heightForCustomCell(fromIdentifier: CellIdentifier.OfferMessageCell, calculatorType:.AutoLayout) { (cell) -> () in
                
                OfferMessageCellConfigurator(cell: cell).configureCellText(data: [.Model:message as Any])
            }
        }
        
        return height
    }
    
    
    
    // MARK: - Offer cell delegate
    
    func offerCell(
        cell: MessageOfferCell,
        didPressButtonWithOfferStatus offerStatus: OfferStatus,
        forIndexPath indexPath: NSIndexPath,
        startAnimation: () -> ()) {
        
        // if everything is complete, do the animation:
        startAnimation()
    }
    
    
    
    // MARK: - Table view controller functions
    
    func insertAtBottom(forRole role: Role) {

        var rowAnimation: UITableViewRowAnimation
        
        switch role {
        case .Incomming:
            rowAnimation = UITableViewRowAnimation.Left
        case .Outgoing:
            rowAnimation = UITableViewRowAnimation.Right
        default:
            rowAnimation = UITableViewRowAnimation.Automatic
        }
        
        var ip = NSIndexPath(forRow: messages.endIndex - 1, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([ip], withRowAnimation: rowAnimation)
    }
    
    
    func scrollToBottom(animate: Bool = false) {

        let index: Int = self.conversation!.messages.endIndex - 1
        self.tableView.scrollToRowAtIndexPath(
            NSIndexPath(forRow: index, inSection: 0),
            atScrollPosition: UITableViewScrollPosition.Bottom,
            animated: animate)
        
    }

    

    // MARK: - Model observer
    
    func removeObservers() {
        conversation?.removeObserver(self, forKeyPath: ObservableConversation.messageList, context: &newMessagesListContext)
        conversation?.removeObserver(self, forKeyPath: ObservableConversation.incommingUser, context: &userJoinedOrLeft)
        conversation?.removeObserver(self, forKeyPath: ObservableConversation.authenticated, context: &userAuthenticate)
    }
    
    func addObservers() {
        
        println("addObservers")
        
        conversation?.addObserver(self, forKeyPath: ObservableConversation.messageList, options: nil, context: &newMessagesListContext)
        conversation?.addObserver(self, forKeyPath: ObservableConversation.incommingUser, options: NSKeyValueObservingOptions.New, context: &userJoinedOrLeft)
        conversation?.addObserver(self, forKeyPath: ObservableConversation.authenticated, options: NSKeyValueObservingOptions.New, context: &userAuthenticate)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        println("will observe")
        
        if context == &newMessagesListContext {
            
            println("******** will observe with context **********")
            
            // If the array is empty, it returns nil
            if let lastMessage = self.conversation?.messages.last {
                
                let m: Message = lastMessage
                self.insertAtBottom(forRole: m.role)
                self.scrollToBottom(animate: true)
                
            }
        }
        
        if context == &userJoinedOrLeft {
            
            var ac = UIAlertController(title: "User left or joined", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            ac.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                ac.removeFromParentViewController()
            }))
            
            if (change[NSKeyValueChangeNewKey] as! Bool) == true {
                
                ac.message = "USER JOINED"
                println("******** USER JOINED **********")
            } else {
                ac.message = "USER LEFT"
                println("******** USER LEFT **********")
            }
            
            self.presentViewController(ac, animated: true, completion: nil)
            
        }
        
        if context == &userAuthenticate {
            
            
            var ac = UIAlertController(title: "Authentication", message: "User is authenticated", preferredStyle: UIAlertControllerStyle.Alert)
            ac.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                ac.removeFromParentViewController()
            }))
            
            self.presentViewController(ac, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    
    // TEST
    
    @IBAction func onTestItemPressed(sender: AnyObject) {
        
        let incommingMessage: Message = Message(id: "123445", owner: "54321", role: Role.Incomming, type: TextType.Text)
        incommingMessage.body = "This is an incomming message"
        conversation?.messageList.list.append(incommingMessage)
        
        
        var time: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC) ) )
        
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            
            let outgoingMessage: Message = Message(id: "8327932874", owner: "23423897", role: Role.Outgoing, type: TextType.Text)
            outgoingMessage.body = "This is an outgoing message"
            self.conversation?.messageList.list.append(outgoingMessage)
            
        }
        
        
        println("TEST")
        
    }
    
    
}
