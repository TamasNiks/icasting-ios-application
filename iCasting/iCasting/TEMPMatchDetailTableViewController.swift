//
//  MatchDetailTableViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 21-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class TEMPMatchDetailTableViewController: UITableViewController {

    var match: NSDictionary?
    let dynamicSection: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return super.numberOfSectionsInTableView(tableView)
//    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section != dynamicSection {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
        return 4
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section != dynamicSection {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
        
        var cell: MatchTableViewCell?
        cell = tableView.dequeueReusableCellWithIdentifier("myCustomCell") as? MatchTableViewCell
        
        if let match = cell {
            cell = MatchTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "myCustomCell")
        }
        
        return cell!
    
    }

}
