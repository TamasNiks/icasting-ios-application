//
//  ArrayDataSource.swift
//  iCasting
//
//  Created by Tim van Steenoven on 16/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit


class ArrayDataSource : NSObject, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    
    
}