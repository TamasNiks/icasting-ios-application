//
//  ClientProfileTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 30/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class ClientProfileTableViewController: UITableViewController {

    var matchID: String?
    
    @IBOutlet weak var companySizeCell: UITableViewCell!
    @IBOutlet weak var cocCell: UITableViewCell!
    @IBOutlet weak var aboutUsCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        if let id = matchID {
            MatchCard.get({ (success, failure) -> () in
                
                if let model: MatchCard = success as? MatchCard {
                 
                    self.companySizeCell.detailTextLabel?.text = model.clientProfile?.employees ?? "-"
                    self.cocCell.detailTextLabel?.text = model.clientProfile?.coc ?? "-"
                    self.aboutUsCell.textLabel?.text = model.clientProfile?.about ?? "-"

                    self.tableView.reloadData()
                }
                
            }, id: id)
        }
    }
}
