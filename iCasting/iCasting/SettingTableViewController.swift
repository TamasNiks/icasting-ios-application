//
//  SettingTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 12/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit


class SettingTableViewController: UITableViewController {

    enum ReuseIdentifiers: String {
        case LogOut = "logoutCellID"
        case ChangeCastingObject = "changeCastingObjectCellID"
    }
    
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
        

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }*/

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath) {
            
            if let reuseIdentifier = cell.reuseIdentifier {
                
                switch reuseIdentifier {
                    
                case ReuseIdentifiers.LogOut.rawValue:
                    
                    Auth().logout() { failure in
                        if failure == nil {
                            println("Logout successfully: access_token is now unset")
                            self.performSegueWithIdentifier("unwindToLogin", sender: self)
                        }
                    }
                    
                case ReuseIdentifiers.ChangeCastingObject.rawValue:
                    
                    self.performSegueWithIdentifier("unwindToChooseCastingObject", sender: self)
                    
                default:
                    println("Warning: Not added to reuseIdentifiers enum.")
                }
            }
            
            cell.setSelected(false, animated: true)
        }
    
    }

    
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }


}
