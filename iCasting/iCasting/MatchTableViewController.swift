//
//  MatchTableViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 20-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class MatchTableViewController: ICTableViewController, MatchCardObserver {

    let match: MatchCollection = MatchCollection()
    
    // MARK: - ViewController Life cycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        setModel(match)
        firstLoadRequest()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func requestSucceedWithModel(model: ModelRequest) -> Bool {
        
        self.match.filter(field: FilterStatusFields.Closed, allExcept: true)
        
        if self.match.matches.isEmpty {
            self.tableView.setTableHeaderViewWithoutResults(NSLocalizedString("NoMatches", comment: ""))
            return false
        } else {
            self.tableView.setTableHeaderViewWithResults(NSLocalizedString("ActiveFilter", comment: ""))
            return true
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.Match.Detail.rawValue, forIndexPath: indexPath) as! MatchOverviewCell
        cell.configureCell(matchCard)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.match.setMatch(indexPath.row)
        performSegueWithIdentifier(SegueIdentifier.MatchID, sender: self)
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
        // It will automaticaly reload the cell by the viewWillAppear method, this doesn't need to implement this method.
//        if let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow() {
//            self.tableView.reloadRowsAtIndexPaths([indexPath as AnyObject], withRowAnimation: UITableViewRowAnimation.None)
//            self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
//        }
    }
    
    func hasChangedStatus() {}
    
    
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
    
    
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as! MatchDetailTableViewController
        destination.delegate = self
        destination.matchCard = self.match.selectedMatch
    }
}
