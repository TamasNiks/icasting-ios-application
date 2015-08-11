//
//  ICTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 02/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

// This struct helps to get the right sections if a tableview consists of static sections, this means predefined sections which are always there, and dynamic sections, which means sections to loop through and are variable.
struct SectionCount {
    
    var numberOfStaticSections: Int = 0
    var numberOfdynamicSections: Int = 0
    var sections: Int {
        return numberOfStaticSections + numberOfdynamicSections
    }
    func getDynamicSection(section: Int) -> Int {
        return section - numberOfStaticSections
    }
}

class ICTableViewController: UITableViewController {

    var model: ModelRequest?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl?.addTarget(self, action: ("handleRefresh"), forControlEvents: UIControlEvents.ValueChanged)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNotification:", name: "PushNotification", object: nil)
    }
    
    // Sometimes the data model in a detail view will change, for example, accepting / rejecting a match or rating a job. This should inflict the master view as well. When the user navigates back, the cell that presents this data must show the changes as well. Usually, when the model changes, all observers should be notified.
    override func viewWillAppear(animated: Bool) {
        
        if let ip = tableView.indexPathForSelectedRow() {
            tableView.deselectRowAtIndexPath(ip, animated: true)
            tableView.reloadRowsAtIndexPaths([ip as AnyObject], withRowAnimation: UITableViewRowAnimation.None)
        }
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func receivedNotification(notification: NSNotification) {

        println("Did received notification")
    }
    
    func setModel(model: ModelRequest) {
        self.model = model
    }
    
    func firstLoadRequest() {
        
        if let model = model {
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            startAnimatingLoaderTitleView()
            handleRequest()
        }
    }
    
    func endLoadRequest() {
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        stopAnimatingLoaderTitleView()
        refreshControl?.endRefreshing()
    }
    
    func handleRefresh() {
        
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.handleRequest()
        }
    }
    
    func handleRequest() {
        
        model?.get { (failure) -> () in
            self.endLoadRequest()
            if self.requestSucceedWithModel(self.model!) {
                self.tableView.reloadData()
            }
        }
    }
    
    func performErrorHandling(error: ICErrorInfo) {
        
        let message: String = error.localizedDescription
        let ac = UIAlertController(
            title: NSLocalizedString("Error", comment: ""),
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        ac.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in }))
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    func requestSucceedWithModel(model: ModelRequest) -> Bool {
        // Abstract...
        return false
    }
    
    func getModel<U: ModelRequest>(forIndexPath indexPath: NSIndexPath) -> U? {
        // Abstract...
        return nil
    }
    
    func getSectionOfModel(inSection section: Int) -> StringDictionaryArray {
        // Abstract...
        return StringDictionaryArray()
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath, identifier: CellIdentifierProtocol) {
        // Abstract
    }
    
    
    
}
