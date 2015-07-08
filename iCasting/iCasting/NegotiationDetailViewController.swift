//
//  NegotiationDetailTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 06/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class NegotiationDetailViewController:
ChatTextInputViewController,
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
DilemmaCellDelegate
 {
    
    @IBOutlet weak var tableView: UITableView!

    
    var matchID: String?
    var conversation: Conversation?
    
    var messages: [Message] {
        return conversation?.messages ?? [Message]()
    }
    
    var sizingCellProvider  : SizingCellProvider?
    var cellReuser          : CellReuser?
    var keyboardController  : KeyboardController?
    
    var observing: Bool = false
    
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
        prepareViewController()
        super.addKeyValueObserverForTextinput()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if conversation == nil {
            self.initializeModel()
        } else {
            self.conversation?.enterConversation()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.conversation?.leaveConversation()
        self.keyboardController?.removeObserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        // Remove especially the key-value observers
        super.removeKeyValueObserverForTextinput()
        removeKeyValueObservers()
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var vc = segue.destinationViewController as! JobOverviewTableViewController
        vc.matchID = self.matchID
    }
    
    
    // MARK: Init functions
    
    private func prepareViewController() {
        
        self.sizingCellProvider = SizingCellProvider(tableView: tableView)
        self.cellReuser = CellReuser(tableView: tableView)

        // Create a keyboard controller with views to handle keyboard events
        self.keyboardController = KeyboardController(views: [self.tableView, self.inputToolbar])
        self.keyboardController?.setObserver()
        
        self.addGestureRecognizer()
    }
    
    
    private func initializeModel() {
        
        if let ID = matchID {
            conversation = Conversation(matchID: ID)
        }
        
        // Get all the current messages available from the server
        // TODO: For best results, you should get the latest 20 messages and load another
        
        self.showWaitOverlay()
        
        conversation?.get() { failure in
            
            self.removeAllOverlays()
            
            if self.messages.isEmpty == false {
                
                println("ConversationTableViewController: request finnished")
                
                self.tableView.reloadData()
                self.scrollToBottom()
                self.addKeyValueObservers()
            }
        }
    }
    

    private func addGestureRecognizer() {
        
        let tgr: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGestureRecognizer:")
        self.tableView.addGestureRecognizer(tgr)
    }
    
}





// MARK: - DATA SOURCE

extension NegotiationDetailViewController {

    // MARK: Table view data source methods

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.messages.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = getAndConfigCell(indexPath) {
            
            return cell
            
        } else {
            
            return getDefaultCell(forIndexPath: indexPath)
        }
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return getHeightForCell(indexPath)
    }
    

    // MARK: Data source helper methods
    
    func getModel(forIndexPath indexPath: NSIndexPath) -> Message {
        
        return messages[indexPath.row]
    }
    
    
    func getDefaultCell(forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(
            CellIdentifier.Message.SystemMessageCell.rawValue,
            forIndexPath: indexPath) as! UITableViewCell
    }
    
    
    func getAndConfigCell(indexPath: NSIndexPath) -> UITableViewCell? {
        
        let message: Message = getModel(forIndexPath: indexPath)

        if let
            identifier = CellIdentifier.Message.fromTextType(message.type),
            cellReuser = self.cellReuser {
                
            let cell: UITableViewCell? = cellReuser.reuseCell(identifier, indexPath: indexPath)
            let cellConfigurator = cellReuser.getConfigurator()
            
            let data: [CellKey:Any] = [CellKey.Model:message as Any, CellKey.IndexPath:indexPath, CellKey.Delegate:self]
            cellConfigurator?.configureCell(data: data)
            
            // For changes inside a message, add a changeObserver
            self.addChangeObserver(forMessage: message, withCellIdentifier: identifier)
                
            return cell
        }
        
        return nil
    }



    func getHeightForCell(indexPath: NSIndexPath) -> CGFloat {
        
        let message: Message = getModel(forIndexPath: indexPath) //messages[indexPath.row]
        let identifier = CellIdentifier.Message.fromTextType(message.type)
        var height: CGFloat = 60
        
        // Check if a specific text type is bound with a cell identifier, extra safe check
        if let _identifier = identifier {
            
            // Exclude the cell, that should not get measured
            if _identifier != CellIdentifier.Message.SystemMessageCell {
                
                // The sizing cell provider gets the right cell once depending on the identifier. It asks to configure the cell, so it can measure the height based on the content through an calculator strategy
                height = sizingCellProvider!.heightForCustomCell(fromIdentifier: _identifier, calculatorType:.AutoLayout) { (cellConfigurator) -> () in
                    
                    cellConfigurator?.configureCellText(data: [.Model:message as Any])
                }
            }
        }

        return height
    }
}




// MARK: - DELEGATE AND HELPERS

extension NegotiationDetailViewController {

    
    func configureCell(forMessage message: Message, andCell cell: UITableViewCell) {
        
        let cellIdentifier = CellIdentifier.Message.fromTextType(message.type)
        let factory = CellConfiguratorFactory(cellIdentifier: cellIdentifier, cell: cell)
        if let configurator = factory.getConfigurator() {
            configurator.configureCell(data: [CellKey.Model:message as Any])
        }
    }
    
    // MARK: Offer cell delegate
    
    func offerCell(
        cell: UITableViewCell,
        didPressButtonWithOfferStatus dilemmaStatus: DilemmaStatus,
        forIndexPath indexPath: NSIndexPath,
        startAnimation: () -> ()) {
        
            
            let message = self.getModel(forIndexPath: indexPath)
            
            switch dilemmaStatus {
                
            case DilemmaStatus.Accept:
                
                if message.type == TextType.Offer {
                    
                    (self.conversation as! MessageCommunicationProtocol).acceptOffer(message) { error in
                        
                        startAnimation()
                    }
                }
                
                if message.type == TextType.ContractOffer {

                    (self.conversation as! MessageCommunicationProtocol).acceptContract(message) { error in
                        
                        // The animation will restart, because after the cell configuration, the state already has been set.
                        self.configureCell(forMessage: message, andCell: cell)
                        startAnimation()
                    }
                }
                
                if message.type == TextType.RenegotationRequest {
                    
                    (self.conversation as! MessageCommunicationProtocol).acceptRenegotiationRequest(message) { error in
                        
                        startAnimation()
                    }
                }
                
            case DilemmaStatus.Reject:
                
                if message.type == TextType.Offer {
                    
                    (self.conversation as! MessageCommunicationProtocol).rejectOffer(message) { error in
                        
                        startAnimation()
                    }
                }
                
                if message.type == TextType.ContractOffer {
                    
                    (self.conversation as! MessageCommunicationProtocol).rejectContract(message) { error in
                        
                        // The animation will restart, because after the cell configuration, the state already has been set.
                        self.configureCell(forMessage: message, andCell: cell)
                        startAnimation()
                    }
                }
                
                if message.type == TextType.RenegotationRequest {
                    
                    (self.conversation as! MessageCommunicationProtocol).rejectRenegotiationRequest(message) { error in
                        
                        startAnimation()
                    }
                }
            }
    }
    

    // MARK: Table view controller functions
    
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




// MARK: - OBSERVING

extension NegotiationDetailViewController {
    
    
    func addKeyValueObservers() {
        conversation?.addObserver(self, forKeyPath: ObservableConversation.messageList, options: nil, context: &newMessagesListContext)
        conversation?.addObserver(self, forKeyPath: ObservableConversation.incommingUser, options: NSKeyValueObservingOptions.New, context: &userJoinedOrLeft)
        conversation?.addObserver(self, forKeyPath: ObservableConversation.authenticated, options: NSKeyValueObservingOptions.New, context: &userAuthenticate)
        observing = true
    }
    
    func removeKeyValueObservers() {
        if observing {
            conversation?.removeObserver(self, forKeyPath: ObservableConversation.messageList, context: &newMessagesListContext)
            conversation?.removeObserver(self, forKeyPath: ObservableConversation.incommingUser, context: &userJoinedOrLeft)
            conversation?.removeObserver(self, forKeyPath: ObservableConversation.authenticated, context: &userAuthenticate)
            observing = false
        }
    }
    
    func addChangeObserver(forMessage message: Message, withCellIdentifier cellIdentifer: CellIdentifier.Message?) {
        
        func changeWithConfigurator(cell: UITableViewCell) {
            let factory = CellConfiguratorFactory(cellIdentifier: cellIdentifer, cell: cell)
            if let configurator = factory.getConfigurator() {
                println("WILL CONFIGURE")
                configurator.configureCell(data: [CellKey.Model:message as Any])
            }
        }

        message.notifyChange = { (message: Message, index: Int) in

            let ip = NSIndexPath(forRow: index, inSection: 0)
            if let cell = self.tableView.cellForRowAtIndexPath(ip) {
                self.tableView.reloadRowsAtIndexPaths([ip], withRowAnimation: UITableViewRowAnimation.Middle) // or change with configurator, see func above
            }
        }
    }
    
    // Observe change on properties, like if there is a new message and wether a user joined or left
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
            
            if (change[NSKeyValueChangeNewKey] as! Bool) == true {
                println("******** USER JOINED **********")
            } else {
                println("******** USER LEFT **********")
            }
        }
        
        if context == &userAuthenticate {
            
            // EXPERIMENT: Show a short message
            DodoBarDefaultStyles.cornerRadius = 0
            DodoPresets.Success.style.bar.backgroundColor = UIColor.ICGreenColor()
            DodoLabelDefaultStyles.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            self.view.dodo.style.bar.animationShow = DodoAnimations.Fade.show
            self.view.dodo.style.bar.animationHide = DodoAnimations.Fade.hide
            self.view.dodo.style.leftButton.icon = .Close
            self.view.dodo.style.bar.hideAfterDelaySeconds = 2
            self.view.dodo.style.bar.hideOnTap = true
            self.view.dodo.success("Conversation active")
        }
        
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
}




// MARK: TEXT INPUT TOOLBAR

extension NegotiationDetailViewController {

    // MARK: Add compatibility for text input field: JSQ Messages Input Toolbar Delegate
    
    override func messagesInputToolbar(toolbar: JSQMessagesInputToolbar!, didPressRightBarButton sender: UIButton!) {
        
        if toolbar.sendButtonOnRight {
            let message = currentlyComposedMessageText()
            self.didPressSendButton(sender, withMessageText: message, date: NSDate())
        } else {
            println("AccessoryButton pressed")
        }
    }
    

    func didPressSendButton(button: UIButton, withMessageText messageText: String, date: NSDate) {
        
        if let messageToSend = validateMessage(messageText) {
            self.conversation?.sendMessage(messageToSend, callBack: { (error) -> () in
                println("POSSIBLE ERROR")
                println(error)
                super.emptyInput()
            })
            println("didPressedSendButton")
        }
    }
    
    
    func validateMessage(text: String) -> String? {
        
        let messageToSend = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return messageToSend.isEmpty ? nil : messageToSend
    }
    
    // When tapped on the tableview, the keyboard will hide
    func handleTapGestureRecognizer(reconizer: UIGestureRecognizer) {
        
        println("handleTapGestureRecognizer")
        self.inputToolbar.contentView.textView.resignFirstResponder()
    }
}



