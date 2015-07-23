//
//  NegotiationTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 04/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit


class NegotiationsTableViewController: UITableViewController {

    var match: Match = Match()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl?.addTarget(self, action: ("handleRequest"), forControlEvents: UIControlEvents.ValueChanged)

        firstLoadRequest()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func firstLoadRequest() {
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        startAnimatingLoaderTitleView()
        handleRequest()
    }
    
    func endLoadRequest() {
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        stopAnimatingLoaderTitleView()
        refreshControl?.endRefreshing()
    }
    
    func handleRequest() {
        
        self.match.get() { failure in

            self.endLoadRequest()
            
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.NegotiationOverview.Default.rawValue, forIndexPath: indexPath) as! ConversationOverviewCell

        configCell(cell, indexPath: indexPath)
        
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.match.setMatch(indexPath.row)
        performSegueWithIdentifier("showConversation", sender: self)
    }
 
    
    // MARK: End data source
    
    func getModel(forIndexPath indexPath: NSIndexPath) -> MatchCard {
        
        return match.matches[indexPath.row]
    }
    
    func configCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        
        if let cell = cell as? ConversationOverviewCell {


            let matchAtIndex = self.getModel(forIndexPath: indexPath)
            let data: [Fields: String] = matchAtIndex.getData([.JobTitle, .ClientName, .ClientCompany, .ClientAvatar])
            
            func setSubtitle() {
                
                cell.customSubtitle.font = UIFont.fontAwesomeOfSize(cell.customSubtitle.font.pointSize)
                
                
                let buildingIcon = String.fontAwesomeIconWithName(FontAwesome.Building)
                let userIcon = String.fontAwesomeIconWithName(FontAwesome.User)
                let clientCompany = data[.ClientCompany]
                let clientName = data[.ClientName]
                
                var cellText = String()
                
                if clientCompany != "-" {
                    cellText += buildingIcon
                    cellText += " \(clientCompany!)" //\u{2003}
                } else if clientName != "-" {
                    cellText += userIcon
                    cellText += " \(clientName!)"
                } else {
                    cellText += String()
                }
                
                cell.customSubtitle.text = cellText//data[.ClientCompany]
            }
            
            cell.customTitle.text = data[.JobTitle]
            setSubtitle()
            
            
            let base64: String = data[.ClientAvatar]!
            if let image: UIImage = ICImages.ImageWithString(base64).image {
                cell.customImageView.image = image
            } else {
                cell.customImageView.image = ICImages.PlaceHolderClientAvatar.image
            }
            
            cell.customImageView.makeRound(35)
            
        }
        

        
        
//        customIconCompany.font = UIFont.fontAwesomeOfSize(20)
//        customIconCompany.text = String.fontAwesomeIconWithName(FontAwesome.Building)
//        customIconClient.font = UIFont.fontAwesomeOfSize(20)
//        customIconClient.text = String.fontAwesomeIconWithName(FontAwesome.User)
//        
//        customCompany.text = item.general[.ClientCompany]
//        customClient.text = item.general[.ClientName]
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        let vc = segue.destinationViewController as! NegotiationDetailViewController
        //vc.hidesBottomBarWhenPushed = true
        vc.matchID = self.match.selectedMatch!.getID(FieldID.MatchCardID)
        
    }


}
