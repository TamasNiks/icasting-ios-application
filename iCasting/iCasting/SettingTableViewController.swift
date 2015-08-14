//
//  SettingTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 12/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath) {
            
            if let reuseIdentifier = cell.reuseIdentifier {
                
                switch reuseIdentifier {
                    
                case CellIdentifier.Settings.LogOut.rawValue:
                    
                    showWaitOverlay()
                    
                    Auth.logout() { [weak self] failure in
                        
                        self?.removeAllOverlays()
                        
                        if let failure = failure {
                            println("DEBUG - SettingTableViewController: \(failure)")
                            return
                        }
                        
                        println("Logout request successfully, unwind to login")
                        self?.performSegueWithIdentifier(SegueIdentifier.Unwind.Login, sender: self)
                    }
                    
                case CellIdentifier.Settings.ChangeCastingObject.rawValue:
                    
                    self.performSegueWithIdentifier(SegueIdentifier.Unwind.CastingObjects, sender: self)
                    
                default:
                    
                    NSException(name: "CellIdentifierException", reason: "Not added to reuseIdentifiers enum.", userInfo: nil)
                }
            }
            
            cell.setSelected(false, animated: true)
        }
    
    }

}
