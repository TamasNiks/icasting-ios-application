//
//  NegotiationTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 04/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class NegotiationsTableViewController: ICTableViewController {

    let match: MatchCollection = MatchCollection()
    
    // MARK: - Table view controller life cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setModel(match)
        firstLoadRequest()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func requestSucceedWithModel(model: ModelRequest) -> Bool {
        
        self.match.filter([.Negotiations, .Completed])
        
        if self.match.matches.isEmpty {
            self.tableView.setTableHeaderViewWithoutResults(NSLocalizedString("NoNegotiations", comment: ""))
            return false
        } else {
            self.tableView.tableHeaderView = nil
            return true
        }
    }
    
    
    func getModel(forIndexPath indexPath: NSIndexPath) -> MatchCard {
        
        return match.matches[indexPath.row]
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        // Return the number of sections.
        return 1
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        // Return the number of rows in the section.
        return self.match.matches.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.NegotiationOverview.Default.rawValue,
            forIndexPath: indexPath) as! ConversationOverviewCell
        
        let matchCard = self.getModel(forIndexPath: indexPath)
        cell.configureCell(matchCard)
        
        return cell
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.match.setMatch(indexPath.row)
        performSegueWithIdentifier(SegueIdentifier.Conversation, sender: self)
    }
 
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let vc = segue.destinationViewController as! ConversationViewController
        //vc.hidesBottomBarWhenPushed = true
        vc.matchID = self.match.selectedMatch!.getID(FieldID.MatchCardID)
        vc.matchCard = self.match.selectedMatch!
    }
}
