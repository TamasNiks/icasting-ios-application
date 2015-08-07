//
//  NotificationsTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 22/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class NotificationsTableViewController: UITableViewController {

    let NUM_SECTIONS: Int = 1
    
    var model: Notifications = Notifications()
    
    @IBAction func onStopTapped(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)

    }
    
    // MARK: ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstLoadRequest()
    }
    
    func firstLoadRequest() {
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        startAnimatingLoaderTitleView()
        handleRequest()
    }
    
    func endLoadRequest() {
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
//        let blurredBackgroundView = BlurredBackgroundView(frame: CGRectZero)
//        tableView.backgroundView = blurredBackgroundView
//        tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurredBackgroundView.blurView.effect as! UIBlurEffect)
        
        stopAnimatingLoaderTitleView()
        refreshControl?.endRefreshing()
    }
    
    
    func handleRequest() {
    
        model.get { (failure) -> () in
            
            self.endLoadRequest()
            self.tableView.reloadData()
        }
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        self.setTabBarVisible(true, animated: true)
//    }

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
        return model.notifications.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        let item = model[indexPath.row]
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