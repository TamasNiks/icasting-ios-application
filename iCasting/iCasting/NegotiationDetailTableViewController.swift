//
//  ConversationTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 06/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class NegotiationDetailTableViewController: UITableViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    var matchID: String?
    var conversation: Conversation?
    
    
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.initializeFooterView()
    
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let ID = matchID {
            conversation = Conversation(matchID: ID)
        }
        
        // Get all the current messages available from the server
        conversation?.requestMessages() {
            
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        

        // Configure the cell...
        var cell: UITableViewCell?
        
        let messages:[Message]? = self.conversation?.messages
        if let messages = messages {
            
            let message: Message = messages[indexPath.row]
            
            
            if message.type == TextType.SystemText {
                cell = tableView.dequeueReusableCellWithIdentifier(
                    MessageCellIdentifier.SystemMessageCell,
                    forIndexPath: indexPath) as! SystemMessageCell
                
                (cell as! SystemMessageCell).systemMessageLabel.text = message.body
                
            } else {
                
                cell = tableView.dequeueReusableCellWithIdentifier(
                MessageCellIdentifier.MessageCell,
                forIndexPath: indexPath) as! MessageCell
                
                if message.role == Role.User {
                    (cell as! MessageCell).rightMessageLabel.text = message.body
                    (cell as! MessageCell).leftMessageLabel.hidden = true
                } else {
                    (cell as! MessageCell).leftMessageLabel.text = message.body
                    (cell as! MessageCell).rightMessageLabel.hidden = true
                }
            }
            
        }
        
        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
//        
//        if cell is MessageCell {
//           (cell as! MessageCell).rightMessageLabel.
//        }
//        
        return 60
    }
    
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
}
