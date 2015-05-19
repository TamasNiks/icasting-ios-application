//
//  UserTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 15/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//
// This castingobject detail controler handles the overview of the current user

import UIKit

class CODetailTableViewController: UITableViewController {

    
    @IBOutlet weak var tableHeaderView: UIView!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    
//    @IBOutlet weak var roleCell: UITableViewCell!
    @IBOutlet weak var creditCell: UITableViewCell!
    @IBOutlet weak var experienceCell: UITableViewCell!
    @IBOutlet weak var profileLevelCell: UITableViewCell!
    @IBOutlet weak var jobRatingCell: UITableViewCell!
    
    func configureCells() {
        
        let user: User = User.sharedInstance
        if let general = user.getGeneral() {
        
            let castingObject: CastingObjectValueProvider = user.castingObject
            
            avatar.image = ICImages.ImageWithString(castingObject.avatar ?? String()).image
            displayName.text = castingObject.name
            creditCell.detailTextLabel?.text = "\(general.credits)"
            
            experienceCell.detailTextLabel?.text = castingObject.experience
            jobRatingCell.detailTextLabel?.text = castingObject.jobRating
            //roleCell.detailTextLabel?.text = general.roles![0]//String(", ").join(general.roles!)
        }
        
        avatar.makeRound(40)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        println("SELECTED CASTING OBJECT")
        println(User.sharedInstance.castingObject.castingObject)
        
        var rect: CGRect = tableHeaderView.frame
        rect.size.height = 150
        tableHeaderView.frame = rect
        
        configureCells()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }


}
