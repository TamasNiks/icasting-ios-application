//
//  ConversationViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 06/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit



class ConversationViewController: ChatTextInputViewController,
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
DilemmaCellExtendedButtonDelegate
 {
    enum PopUpState { case Success, Error }
    
    @IBOutlet weak var tableView: UITableView!
    
    // The matchID is needed to get the right conversation
    var matchID: String?
    
    // To get access to specific features of the matchcard we need to get this passed as well
    weak var matchCard: MatchCard!
    
    // The conversation is the entry point for the message data model. It also handles the traffic between Socket and controller
    var conversation: Conversation?
    
    // A shortcut to the message array. Given an empty message array so the table view can initialze it's rendering before the model gets it's data
    var messages: [Message] {
        return conversation?.messages ?? [Message]()
    }
    
    var sizingCellProvider  : SizingCellProvider!
    var cellReuser          : CellReuser!
    var keyboardController  : KeyboardController?
    var ratingController    : RatingController!
    
    var observing: Bool = false
    var viewIsLoaded: Bool = false
    
    // Contexts are used by the KVO, to decide and respond on what kind of path has changed
    var newMessagesListContext: Int = 0
    var userJoinedOrLeft: Int = 0
    var userAuthenticate: Int = 0
    
    struct ObservableConversationPath {
        static var messageList: String = "messageList.list"
        static var incommingUser: String = "incommingUser"
        static var authenticated: String = "authenticated"
    }

    
    // MARK: - Viewcontroller Life cycle
    
    var overlay: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViewController()
        super.addKeyValueObserverForTextinput()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        if !viewIsLoaded {
            viewIsLoaded = true
            prepareModel()
            handleRequest()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    deinit {
        println("Will deinit ConversationViewController")
        conversation?.leaveConversation()
        keyboardController?.removeObserver()
        super.removeKeyValueObserverForTextinput()
        removeKeyValueObservers()
        
        for gr in tableView.gestureRecognizers as! [UIGestureRecognizer] {
            tableView.removeGestureRecognizer(gr)
        }
    }
    

    // MARK: Init functions
    
    private func prepareViewController() {
        
        DodoBarDefaultStyles.cornerRadius = 5
        DodoLabelDefaultStyles.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        DodoPresets.Success.style.bar.backgroundColor = UIColor.ICGreenColor()
        
        let ccf = MessageCellConfiguratorFactory()
        sizingCellProvider = SizingCellProvider(tableView: tableView, cellConfiguratorFactory: ccf)
        cellReuser = CellReuser(tableView: tableView, cellConfiguratorFactory: ccf)

        // Create a keyboard controller with views to handle keyboard events
        keyboardController = KeyboardController(views: [tableView, inputToolbar])
        keyboardController?.setObserver()
        
        // Create a controller to give the rating
        ratingController = RatingController(viewController: self)
        
        addGestureRecognizer()
        
        // tableView.rowHeight = UITableViewAutomaticDimension
        // tableView.estimatedRowHeight = 100
    }
    
    
    private func prepareModel() {
        
        if let ID = matchID {
            conversation = Conversation(matchID: ID)
            conversation?.delegate = self
        }
    }
    
    private func handleRequest() {
        
        // Get all the current messages available from the server
        // TODO: For best results, you should get the latest 20 messages and load another
        
        showWaitOverlay()
        
        // TODO: Only make the conversation active if the job is not marked completed
        
        conversation?.get() { failure in
            
            self.removeAllOverlays()
            
            if let failure = failure {
                
                self.performErrorHandling(failure)
                return
            }
            
            if self.messages.isEmpty == false {
                
                println("ConversationTableViewController: request finnished, will reload the table")
                self.tableView.reloadData()
                self.scrollToBottom()
                self.addKeyValueObservers()
            }
        }
    }

    
    private func addGestureRecognizer() {
        
        let tgr: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGestureRecognizer:")
        tableView.addGestureRecognizer(tgr)
    }
    
    
    private func performErrorHandling(errors: ICErrorInfo) {
        
        let message = errors.localizedFailureReason
        let title = NSLocalizedString("Error", comment: "")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Add a basic action for errors
        var action: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            alertController.removeFromParentViewController()
        }
        
        // If it is a specific network error, apperently the user could not connect because of unavailable internet connection
        if errors.type == ICErrorType.NetworkErrorInfo {
            
            println("ICErrorType.NetworkErrorInfo")
            
            action = UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.handleRequest()
                alertController.removeFromParentViewController()
            })
        }
        
        alertController.addAction(action)
        presentViewController(alertController, animated: true, completion: nil)
    }
}





// MARK: - DATA SOURCE

extension ConversationViewController {

    // MARK: Table view data source methods

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = getAndConfigCell(indexPath) {
            
            return cell
            
        } else {
            
            return getDefaultCell(forIndexPath: indexPath)
        }
    }

    
//    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 100
//    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return getHeightForCell(indexPath)
    }


    // MARK: Data source helper methods
    
    func getModel(forIndexPath indexPath: NSIndexPath) -> Message {
        
        return messages[indexPath.row]
    }
    
    
    
    func getDefaultCell(forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.Message.SystemMessageCell.rawValue,
            forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = "DEBUG: Don't forget to bind the TextType to the CellIdentifier!"
        return cell
    }
    
    
    
    func getAndConfigCell(indexPath: NSIndexPath) -> UITableViewCell? {
        
        let message: Message = getModel(forIndexPath: indexPath)

        if let
            identifier = CellIdentifier.Message.fromTextType(message.type),
            cellReuser = cellReuser {
                
            let cell: UITableViewCell? = cellReuser.reuseCell(identifier, indexPath: indexPath, configuratorType: message.type)
            let cellConfigurator = cellReuser.configuratorFactory.getConfigurator()
                
            if let cc = cellConfigurator as? ReportedCompleteMessageCellConfigurator {
                cc.rated = matchCard.talentHasRated
            }
            
            let data = [
                CellKey.Model : message as Any,
                CellKey.IndexPath : indexPath,
                CellKey.Delegate : self
                ]
                
            cellConfigurator?.configureCell(data: data)
            
            // For changes inside a message, add a changeObserver
            addChangeInMessageObserver(forMessage: message, withCellIdentifier: identifier)
                
            return cell
        }
        
        return nil
    }



    func getHeightForCell(indexPath: NSIndexPath) -> CGFloat {
        
        let message: Message = getModel(forIndexPath: indexPath) //messages[indexPath.row]
        let identifier = CellIdentifier.Message.fromTextType(message.type)
        var height: CGFloat = 60
        
        // Check if a specific text type is bound with a cell identifier, extra safe check
        if let identifier = identifier {
            
            // Exclude the cell, that should not get measured
            if identifier != CellIdentifier.Message.SystemMessageCell {
                
                // The sizing cell provider gets the right cell once depending on the identifier. It asks to configure the cell, so it can measure the height based on the content through an calculator strategy
                height = sizingCellProvider.heightForCustomCell(
                    fromIdentifier: identifier,
                    configuratorType: message.type,
                    calculatorType:.AutoLayout) { (cellConfigurator) -> () in
                    
                        cellConfigurator?.configureCellText(data: [.Model:message as Any])
                }
            }
        }

        return height
    }
}




// MARK: - DELEGATE AND HELPERS

extension ConversationViewController {

    // MARK: dilemma cell delegate used for all kind of offer terms and contract questions
    
    func dilemmaCell(cell: UITableViewCell,
        didPressButtonForState decisionState: DecisionState,
        forIndexPath indexPath: NSIndexPath,
        startAnimation: () -> ()) {
        
            println("did press button")
            
            let message = self.getModel(forIndexPath: indexPath)
            
            let messageCommunication = self.conversation as! MessageCommunicationProtocol
            
            switch decisionState {
                
            case DecisionState.Accept:
                
                if message.type == TextType.Offer {
                    
                    messageCommunication.acceptOffer(message) { error in
                        
                        startAnimation()
                    }
                }
                
                if message.type == TextType.ContractOffer {

                    messageCommunication.acceptContract(message) { error in
                        
                        // The animation will restart, because after the cell configuration, the state already has been set.
                        self.configureCell(forMessage: message, andCell: cell)
                        startAnimation()
                    }
                }
                
                if message.type == TextType.RenegotationRequest {
                    
                    messageCommunication.acceptRenegotiationRequest(message) { error in
                        
                        startAnimation()
                    }
                }
                
                if message.type == TextType.ReportedComplete {
                    
                    messageCommunication.acceptJobCompleted(message) { error in
                        
                        // The animation will restart, because after the cell configuration, the state already has been set.
                        self.configureCell(forMessage: message, andCell: cell)
                        startAnimation()
                    }
                }
                
            case DecisionState.Reject:
                
                if message.type == TextType.Offer {
                    
                    messageCommunication.rejectOffer(message) { error in
                        
                        startAnimation()
                    }
                }
                
                if message.type == TextType.ContractOffer {
                    
                    messageCommunication.rejectContract(message) { error in
                        
                        // The animation will restart, because after the cell configuration, the state already has been set.
                        self.configureCell(forMessage: message, andCell: cell)
                        startAnimation()
                    }
                }
                
                if message.type == TextType.RenegotationRequest {
                    
                    messageCommunication.rejectRenegotiationRequest(message) { error in
                        
                        startAnimation()
                    }
                }
                
                if message.type == TextType.ReportedComplete {
                    
                    messageCommunication.rejectJobCompleted(message) { error in
                        
                        // The animation will restart, because after the cell configuration, the state already has been set.
                        self.configureCell(forMessage: message, andCell: cell)
                        startAnimation()
                    }
                }
        }
    }
    

    // The extended button needs to be controlled by the delegate in three different states: loading state, finished state failure, finished state success
    
    func dilemmaCell(cell: UITableViewCell, didPressDecidedButtonForState decidedState: DecisionState, forIndexPath indexPath: NSIndexPath) {
        
        ratingController.show { [weak self] grade in

            let _grade = grade
            self?.matchCard.rate(grade, callBack: { (failure) -> () in

                println("REQUEST: did rate client request")
                
                if let error = failure {
                    self?.performErrorHandling(error)
                } else {
                    
                    let float: Float = NSString(string: _grade).floatValue
                    self?.matchCard.setLocalTalentRating(float)
                    self?.tableView.reloadRowsAtIndexPaths([indexPath as AnyObject], withRowAnimation: UITableViewRowAnimation.None)
                }
            })
            
        }
    }
    
    
    func configureCell(forMessage message: Message, andCell cell: UITableViewCell) {
        
        //let cellIdentifier = CellIdentifier.Message.fromTextType(message.type)
        let factory = MessageCellConfiguratorFactory(configuratorType: message.type, cell: cell)
        if let configurator = factory.getConfigurator() {
            configurator.configureCell(data: [CellKey.Model:message as Any])
        }
    }
    
    
    // MARK: Table view controller functions
    
    func insertAtBottom(forRole role: MessageRole) {

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
        
        let incommingMessage: Message = Message(id: "123445", owner: "54321", role: MessageRole.Incomming, type: TextType.Text)
        incommingMessage.body = "This is an incomming message"
        conversation?.messageList.list.append(incommingMessage)
        var time: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC) ) )
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            let outgoingMessage: Message = Message(id: "8327932874", owner: "23423897", role: MessageRole.Outgoing, type: TextType.Text)
            outgoingMessage.body = "This is an outgoing message"
            self.conversation?.messageList.list.append(outgoingMessage)
        }
        println("TEST")
    }
}




// MARK: - OBSERVING

extension ConversationViewController : ConversationErrorDelegate {
    
    
    func addKeyValueObservers() {
        conversation?.addObserver(self,
            forKeyPath: ObservableConversationPath.messageList, options: nil, context: &newMessagesListContext)
        conversation?.addObserver(self,
            forKeyPath: ObservableConversationPath.incommingUser, options: NSKeyValueObservingOptions.New, context: &userJoinedOrLeft)
        conversation?.addObserver(self,
            forKeyPath: ObservableConversationPath.authenticated, options: NSKeyValueObservingOptions.New, context: &userAuthenticate)
        observing = true
    }
    
    
    func removeKeyValueObservers() {
        if observing {
            conversation?.removeObserver(self, forKeyPath: ObservableConversationPath.messageList, context: &newMessagesListContext)
            conversation?.removeObserver(self, forKeyPath: ObservableConversationPath.incommingUser, context: &userJoinedOrLeft)
            conversation?.removeObserver(self, forKeyPath: ObservableConversationPath.authenticated, context: &userAuthenticate)
            observing = false
        }
    }
    
    
    func addChangeInMessageObserver(forMessage message: Message, withCellIdentifier cellIdentifer: CellIdentifier.Message?) {

        // There are two options to update a cell. The easiest is just to reload the cell with a prebuild animation. The data source will get the updated model and after going through a cell configurator the cell should reflect the latest changes. The shortcut is to pass the updated message to a cell configurator (see function below). But then you have to take care of visual feedback of a change in a cell to the user in the configurator. Therefor it is better to use the reloadRowsAtIndexPath for incomming changes in messages. It's less of a hassle, less code and it follows the MVC cycle. The outgoing changes in messages (device side changes) will be handled differently.
        
        /*func changeWithConfigurator(cell: UITableViewCell) {
            let factory = CellConfiguratorFactory(cellIdentifier: cellIdentifer, cell: cell)
            if let configurator = factory.getConfigurator() {
                println("WILL CONFIGURE")
                configurator.configureCell(data: [CellKey.Model:message as Any])
            }
        }*/

        // Here we create a closure which can be called later if a change in a particularly message occur
        message.notifyChange = {
            
            [weak self] (message: Message, index: Int) in
            
            let ip = NSIndexPath(forRow: index, inSection: 0)
            if let cell = self!.tableView.cellForRowAtIndexPath(ip) {
                
                // Info: Even though the closure refers to self multiple times, it only captures one strong reference to self.
                self!.tableView.reloadRowsAtIndexPaths([ip], withRowAnimation: UITableViewRowAnimation.Middle)
            }
        }
    }
    
    // Observe change on properties, like if there is a new message and wether a user joined or left
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        println("will observe")
        
        if context == &newMessagesListContext {
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
            
            showAnnouncement("Conversation active", state: PopUpState.Success)
        }
        
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
    
    
    func receivedErrorForConversation(error: ICErrorInfo) {
        showAnnouncement(error.localizedFailureReason, state: PopUpState.Error)
    }
    
    func showAnnouncement(announcement: String, state: PopUpState) {
    
        self.view.dodo.style.bar.animationShow = DodoAnimations.Fade.show
        self.view.dodo.style.bar.animationHide = DodoAnimations.Fade.hide
        self.view.dodo.style.leftButton.icon = .Close
        self.view.dodo.style.bar.hideAfterDelaySeconds = 2
        self.view.dodo.style.bar.hideOnTap = true
        
        switch state {
        case .Success: self.view.dodo.success(announcement)
        case .Error: self.view.dodo.error(announcement)
        }
        
    }
    
}




// MARK: TEXT INPUT TOOLBAR

extension ConversationViewController {

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

extension ConversationViewController {
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let navigationController = segue.destinationViewController as! UINavigationController
        let viewController = navigationController.topViewController as! JobOverviewTableViewController
        viewController.matchID = self.matchID
    }
}


