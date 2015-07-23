//
//  SettingTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 12/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit


class SettingTableViewController: UITableViewController {
    
//    @IBOutlet weak var switchFamilyMemberCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath) {
            
            if let reuseIdentifier = cell.reuseIdentifier {
                
                switch reuseIdentifier {
                    
                case CellIdentifier.Settings.LogOut.rawValue:
                    
                    Auth.logout() { failure in
                        if failure == nil {
                            println("Logout request successfully, unwind to login")
                            self.performSegueWithIdentifier("unwindToLogin", sender: self)
                        } else {
                            println("DEBUG: \(failure)")
                        }
                    }
                    
                case CellIdentifier.Settings.ChangeCastingObject.rawValue:
                    
                    self.performSegueWithIdentifier("unwindToChooseCastingObject", sender: self)
                    
                default:
                    println("Warning: Not added to reuseIdentifiers enum.")
                }
            }
            
            cell.setSelected(false, animated: true)
        }
    
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    //}
}
