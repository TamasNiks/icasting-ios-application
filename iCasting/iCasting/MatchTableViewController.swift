//
//  MatchTableViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 20-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit


class MatchTableViewController: UITableViewController, MatchCardDelegate {

    let match: Match = Match()
    
    @IBAction func onFilterBarButtonTouch(sender: AnyObject) {
        
        let ac = FilterMatchAlertController(resource: match) {
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)

            var statusFieldLocalizationKey: String = "ActiveFilter"
            if let currentStatusField = self.match.currentStatusField {
                statusFieldLocalizationKey = currentStatusField.rawValue
            }
            self.tableView.setTableHeaderViewWithResults(NSLocalizedString(statusFieldLocalizationKey, comment: ""))
        }.configureAlertController()
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    
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
            
            self.match.filter(field: FilterStatusFields.Closed, allExcept: true)
            
            if self.match.matches.isEmpty {
                self.tableView.setTableHeaderViewNoResults(NSLocalizedString("NoMatches", comment: ""))
    
            } else {
                self.tableView.setTableHeaderViewWithResults(NSLocalizedString("ActiveFilter", comment: ""))
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: ("handleRefresh:"), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl?.beginRefreshing()
        handleRequest()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.match.matches.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let matchCard: MatchCard = self.match.matches[indexPath.row]
        var data: [Fields: String] = matchCard.getData([.JobTitle, .JobDescription, .JobDateStart, .ClientAvatar, .Status])
        
        let cell = tableView.dequeueReusableCellWithIdentifier("matchDetailCellIdentifier", forIndexPath: indexPath) as! MatchCell
        cell.configureCell(data)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.match.setMatch(indexPath.row)
        performSegueWithIdentifier("showMatchID", sender: self)
    }
    
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as! MatchDetailTableViewController
        destination.delegate = self
        destination.matchCard = self.match.selectedMatch
    }
    
    
    
    // MARK: MatchDetailViewController Delegates
    
    func didRejectMatch() {
        
        println("DID REJECT MATCH DELEGATE CALL, MATCHES COUNT: %@", self.match.matches.count)
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
