//
//  MatchTableViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 20-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class MatchOverviewCell: UITableViewCell {
    @IBOutlet weak var customTitle: UILabel!
    @IBOutlet weak var customSubtitle: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var customDate: UILabel!
    @IBOutlet weak var customNegotiationIcon: UIImageView!
}


class MatchTableViewController: UITableViewController, MatchDetailDelegate {

    var matchModel: Match = TalentMatch()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.setupLeftMenuButton()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.matchModel.all() { result in
            
            self.matchModel.filter(field: FilterStatusFields.Closed, allExcept: true)
            self.tableView.reloadData()
        }
        
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
        return self.matchModel.matches.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("matchDetailCellIdentifier", forIndexPath: indexPath) as! MatchOverviewCell

        var data: [Fields: String] = self.matchModel.getMatchData([.JobTitle, .JobDescription, .JobDateStart, .ClientAvatar, .Status], index: indexPath.row)
        
        
        //var info: [String:String] = self.match.getCellInfo(index: indexPath.row)
        cell.customTitle.text = data[.JobTitle]
        cell.customSubtitle.text = data[.JobDescription]
        cell.customDate.text = String(format: "Start: %@", data[.JobDateStart] ?? "no date")
        
        var base64: String = data[.ClientAvatar]!
        if let image: UIImage = ICImages.ImageWithString(base64).image {
            cell.customImageView.image = image
        } else {
            cell.customImageView.image = ICImages.PlaceHolderClientAvatar.image
        }
        
        
        // Configure the cell conform the status of the match (talent accepted, negotiation, pending)
        
        if let status = data[.Status] {
            if let statusField: FilterStatusFields = FilterStatusFields.allValues[status] {
                if statusField == .Negotiations || statusField == .TalentAccepted {
                    cell.customImageView.makeRound(35, borderWidth: 4, withBorderColor: UIColor(red: 123/255, green: 205/255, blue: 105/255, alpha: 1))
                    if statusField == .Negotiations {
                        cell.customNegotiationIcon.hidden = false
                    }
                    return cell
                }
            }
        }
        
        cell.customImageView.makeRound(35, borderWidth:nil)
        return cell
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        //var item: NSDictionary = self.match.matches[indexPath.row] as! NSDictionary
        self.matchModel.setMatch(indexPath.row)
        performSegueWithIdentifier("showMatchID", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        var destination = segue.destinationViewController as! MatchDetailTableViewController
        destination.delegate = self
        destination.match = self.matchModel
    }
    
    // MARK: MatchDetailViewController Delegates
    
    func didRejectMatch() {
        
        println("DID REJECT MATCH DELEGATE CALL, MATCHES COUNT: %@", self.matchModel.matches.count)
        
        if let indexPath: NSIndexPath? = self.tableView.indexPathForSelectedRow() {
            self.tableView.deleteRowsAtIndexPaths([indexPath as! AnyObject], withRowAnimation: UITableViewRowAnimation.Left)
        }
    }
    
    func didAcceptMatch() {
        
        println("DID ACCEPT MATCH DELEGATE CALL")
        
        if let indexPath: NSIndexPath? = self.tableView.indexPathForSelectedRow() {
            self.tableView.reloadRowsAtIndexPaths([indexPath as! AnyObject], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    
    /*func setupLeftMenuButton() {
        let leftDrawerButton = DrawerBarButtonItem(target: self, action: "leftDrawerButtonPress:")
        self.navigationItem.setLeftBarButtonItem(leftDrawerButton, animated: true)
    }
    
    // MARK: - Button Handlers
    
    func leftDrawerButtonPress(sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
    }*/
    
}
