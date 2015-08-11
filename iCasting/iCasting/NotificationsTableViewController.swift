//
//  NotificationsTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 22/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//


//        let blurredBackgroundView = BlurredBackgroundView(frame: CGRectZero)
//        tableView.backgroundView = blurredBackgroundView
//        tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurredBackgroundView.blurView.effect as! UIBlurEffect)

import UIKit

class NotificationsTableViewController: ICTableViewController {

    let NUM_SECTIONS: Int = 1
    
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
        return NUM_SECTIONS
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return notifications.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        let item = notifications[indexPath.row]
        cell.textLabel?.text = item.title
        
        var descAttrStr = NSMutableAttributedString(string: item.desc, attributes: [NSForegroundColorAttributeName: UIColor.ICTextLightGrayColor()])
        var dateAttrStr = NSMutableAttributedString(string: item.date, attributes: [NSForegroundColorAttributeName: UIColor.ICTextDarkGrayColor()])
        descAttrStr.appendAttributedString(NSMutableAttributedString(string:"\r"))
        descAttrStr.appendAttributedString(dateAttrStr)
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.attributedText = descAttrStr
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
}