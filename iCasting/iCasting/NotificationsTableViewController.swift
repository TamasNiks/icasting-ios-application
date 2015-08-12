//
//  NotificationsTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 22/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class NotificationsTableViewController: ICTableViewController {

    let kNumSections: Int = 1
    
    var notifications: Notifications = Notifications()
    
    @IBAction func onStopTapped(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setModel(notifications)
        firstLoadRequest()
    }
    
    override func requestSucceedWithModel(model: ModelRequest) -> Bool {
        
        if self.notifications.isEmpty {
            self.tableView.setTableHeaderViewWithoutResults(NSLocalizedString("NoResults", comment: ""))
            return false
        }
            
        let localizedFormat = NSLocalizedString("notifications.tableview.header.last", comment: "")
        let numberOfNotifications = self.notifications.count
        self.tableView.setTableHeaderViewWithResults(String(format: localizedFormat, "\(numberOfNotifications)"))
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return kNumSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return notifications.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.NotificationsOverview.Default.rawValue, forIndexPath: indexPath) as! UITableViewCell
        let item = notifications[indexPath.row]
        cell.configureCell(item)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }
}