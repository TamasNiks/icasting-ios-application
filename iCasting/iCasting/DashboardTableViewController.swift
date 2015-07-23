//
//  UserTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 15/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//
// This castingobject detail controler handles the overview of the current user

import UIKit

struct SegueIdentifier {
    static let Settings = "settingsSegueID"
    static let Family = "unwindToFamilySegueID"
}



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
        
        configureNavigationItem()
        configureTableHeaderView()
        configureCells()
    }

    
    func configureNavigationItemView() {
        
        let iconSize: CGFloat = 35
        let margin: CGFloat = 5
        
        let settingsButton = UIButton(frame: CGRectMake(iconSize, 0, iconSize, iconSize))
        settingsButton.setImage(UIImage(named: "settings3"), forState: UIControlState.Normal)
        settingsButton.addTarget(self, action: "handleSettingsBarButtonItemTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        settingsButton.frame.offset(dx: margin, dy: 0)
        
        let groupButton = UIButton(frame: CGRectMake(0, 0, iconSize, iconSize))
        groupButton.setImage(UIImage(named: "group"), forState: UIControlState.Normal)
        groupButton.addTarget(self, action: "handleSwitchFamilyBarButtonItemTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        groupButton.frame.offset(dx: margin, dy: 0)
        
        // Views
        let customViewForBarButtonItems = UIView(frame: CGRectMake(0, 0, iconSize*2, iconSize))
        customViewForBarButtonItems.addSubview(settingsButton)
        
        if User.sharedInstance.isManager {
            customViewForBarButtonItems.addSubview(groupButton)
        }
        
        let rightBarButtonItem = UIBarButtonItem(customView: customViewForBarButtonItems)
        
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false)
    }
    
    
    
    func configureNavigationItem() {
        
        var switchFamilyMemberBarButtonItem: AnyObject?
        if User.sharedInstance.isManager {
            switchFamilyMemberBarButtonItem = UIBarButtonItem(image: UIImage(named: "group"),
                style: UIBarButtonItemStyle.Plain,
                target: self,
                action: "handleSwitchFamilyBarButtonItemTapped:")
        }
        

        let settingsBarButtonItem: AnyObject = UIBarButtonItem(image: UIImage(named: "settings3"),
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "handleSettingsBarButtonItemTapped:")
        
        var barButtonItems = [settingsBarButtonItem]
        if let item: AnyObject = switchFamilyMemberBarButtonItem {
            barButtonItems.append(item)
        }
        
        self.navigationItem.setRightBarButtonItems(barButtonItems, animated: false)
    }
    
    
    func handleSwitchFamilyBarButtonItemTapped(sender: AnyObject) {
        
        self.performSegueWithIdentifier(SegueIdentifier.Family, sender: self)
    }
    
    
    func handleSettingsBarButtonItemTapped(sender: AnyObject) {
        
        self.performSegueWithIdentifier(SegueIdentifier.Settings, sender: self)
    }
    
    func configureTableHeaderView() {
        
        var rect: CGRect = tableHeaderView.frame
        rect.size.height = 150
        tableHeaderView.frame = rect
        tableHeaderView.backgroundColor = UIColor.ICShadowRedColor()
    }
    
    func configureCells() {
        
        let user: User = User.sharedInstance
        if let general = user.values {
            
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
