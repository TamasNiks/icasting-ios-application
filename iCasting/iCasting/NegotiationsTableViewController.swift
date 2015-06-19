//
//  NegotiationTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 04/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var customTitle: UILabel!
    @IBOutlet weak var customSubtitle: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    //@IBOutlet weak var customDate: UILabel!

}


class NegotiationsTableViewController: UITableViewController {

    var match: Match = Match()
    
    func handleRefresh(sender: AnyObject) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
        dispatch_after(popTime, dispatch_get_main_queue(), {
            self.handleRequest()
        })
    }
    
    func handleRequest() {
        
        self.match.get() { failure in
            self.refreshControl?.endRefreshing()
            println(failure?.description)
            self.match.filter(field: .Negotiations)
            //println(self.match.matches[1].getData([Fields.JobTitle]))
            
            if self.match.matches.isEmpty {
                self.tableView.setTableHeaderViewWithoutResults(NSLocalizedString("NoNegotiations", comment: ""))
            } else {
                self.tableView.tableHeaderView = nil
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: ("handleRefresh:"), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl?.beginRefreshing()
        handleRequest()
        
        let ac = UIAlertController(
            title: NSLocalizedString("Announcement", comment: ""),
            message: "This feature is in development yet, we will inform you of further versions",
            preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
            style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
        }))
        //self.presentViewController(ac, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.match.matches.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("conversationCellidentifier", forIndexPath: indexPath) as! ConversationCell

        let matchAtIndex: MatchCard = self.match.matches[indexPath.row]
        var data: [Fields: String] = matchAtIndex.getData([.JobTitle, .JobDescription, .JobDateStart, .ClientAvatar])
        
        
        //var info: [String:String] = self.match.getCellInfo(index: indexPath.row)
        cell.customTitle.text = data[.JobTitle]
        cell.customSubtitle.text = data[.JobDescription]
        //cell.customDate.text = String(format: "Start: %@", data[.JobDateStart]!)
        
        var base64: String = data[.ClientAvatar]!
        if let image: UIImage = ICImages.ImageWithString(base64).image {
            cell.customImageView.image = image
        } else {
            cell.customImageView.image = ICImages.PlaceHolderClientAvatar.image
        }
        cell.customImageView.makeRound(35, borderWidth: 4, withBorderColor: UIColor(red: 123/255, green: 205/255, blue: 105/255, alpha: 1))
        
        return cell
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.match.setMatch(indexPath.row)
        performSegueWithIdentifier("showConversation", sender: self)
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        var vc = segue.destinationViewController as! NegotiationDetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.matchID = self.match.selectedMatch!.getID(FieldID.MatchCardID)
        
    }


}
