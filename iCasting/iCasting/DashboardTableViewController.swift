//
//  UserTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 15/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//
// This castingobject detail controler handles the overview of the current user

import UIKit

class DashboardTableViewController: UITableViewController {

    
    @IBOutlet weak var tableHeaderView: UIView!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    
//    @IBOutlet weak var roleCell: UITableViewCell!
    @IBOutlet weak var creditCell: UITableViewCell!
    @IBOutlet weak var experienceCell: UITableViewCell!
    @IBOutlet weak var profileLevelCell: UITableViewCell!
    @IBOutlet weak var jobRatingCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableHeaderView()
        configureCells()
    }

    
    func configureTableHeaderView() {
        
        var rect: CGRect = tableHeaderView.frame
        rect.size.height = 150
        tableHeaderView.frame = rect
        tableHeaderView.backgroundColor = UIColor.ICShadowRedColor()
    }
    
    func configureCells() {
        
        if User.sharedInstance.isManager == false {
            self.navigationItem.rightBarButtonItem = nil //?.enabled = false
        }
        
        let user: User = User.sharedInstance
        if let general = user.getValues() {
            
            let castingObject = user.castingObject
            
            avatar.image = (castingObject.avatar != nil) ? ICImages.ImageWithString(castingObject.avatar!).image : ICImages.PlaceHolderClientAvatar.image
            displayName.text = castingObject.name
            creditCell.detailTextLabel?.text = "\(general.credits)"
            
            experienceCell.detailTextLabel?.text = castingObject.experience
            jobRatingCell.detailTextLabel?.text = castingObject.jobRating
            //roleCell.detailTextLabel?.text = general.roles![0]//String(", ").join(general.roles!)
        }
        
        avatar.makeRound(40)
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
