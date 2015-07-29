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
}
