//
//  CastingObjectsTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//
// This castingobject overview controler handles the overview of all family members (casting objects) of the current user

import UIKit

class CastingObjectCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 85
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size: CGSize = CGSize(width: 50, height: 50) // default cell height is 43
        self.imageView?.makeRound(size.width / 2) //, borderWidth: 0)
        self.imageView?.bounds = CGRectMake(0, 0, size.width, size.height)
    }
}

class FamilyTableViewController: UITableViewController {

    
    /*func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }*/

    // TEST: for the tableViewHeader
    //static var resultCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        setNavigationItemTitle()
        
        if User.sharedInstance.castingObjects.isEmpty { // TEST: || CastingObjectsTableViewController.resultCounter == 0 {
            
            self.tableView.setTableHeaderViewWithoutResults(NSLocalizedString("NoFamilyMembers", comment: ""))
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: UIBarButtonSystemItem.Stop,
                target: self,
                action: "onStopBarButtonPressed:")
            //self.navigationIte
            //TEST: MatchTableViewController.resultCounter++
        } else {
            tableView.tableHeaderView = nil
            tableView.reloadData()
        }
    }

    
    func onStopBarButtonPressed(sender: AnyObject) {
        
        setActivityIndicator()
        
        
        Auth().logout() { failure in
            if failure == nil {
                println("Logout request successfully, unwind to login")
                self.performSegueWithIdentifier("unwindToLogin", sender: self)
            }
        }
    }
    
    func setActivityIndicator() {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        self.navigationItem.titleView = aiv
        aiv.startAnimating()
    }
    
    func setNavigationItemTitle() {
        let format: String = NSLocalizedString("castingobjects.navigationitem.title", comment: "Casting objects navigation bar title")
        self.navigationItem.title = String(format: format, User.sharedInstance.getValues()!.first)
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return User.sharedInstance.castingObjects.count
    }

    
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("castingObjectCellID", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        let castingObject = User.sharedInstance.castingObjectAtIndex(indexPath.row)
        cell.textLabel?.text = castingObject.name
    
        if let avatar = castingObject.avatar {
            cell.imageView?.image = ICImages.ImageWithString(avatar).image
        } else {
            cell.imageView?.image = ICImages.PlaceHolderClientAvatar.image
        }
    
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        (User.sharedInstance as UserCastingObject).setCastingObject(indexPath.row)
        self.performSegueWithIdentifier("showMain", sender: self)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CastingObjectCell.cellHeight
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createHeaderLabel(NSLocalizedString("CastingObjectsHeader", comment: ""))
    }
    
    private func createHeaderLabel(text: String) -> UILabel {
        
        let rect: CGRect = CGRectMake(0, 0, 0, 0)
        let label: UILabel = UILabel(frame: rect)
        // Define the left padding through white spaces, check https://www.cs.tut.fi/~jkorpela/chars/spaces.html
        label.text = "\u{2003}"+text
        label.font = UIFont.boldSystemFontOfSize(12)
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0
        //label.backgroundColor = UIColor(red: 221/255, green: 33/255, blue: 49/255, alpha: 1.0) //UIColor(white: 0.9, alpha: 1.0)
        label.backgroundColor = UIColor.ICDarkenedRedColor() //UIColor(red: 172/255, green: 9/255, blue: 33/255, alpha: 1.0) //UIColor(white: 0.9, alpha: 1.0)
        label.textColor = UIColor.whiteColor()
        return label
    }
    

    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func prepareForUnwindToCastingObjects(segue:UIStoryboardSegue) {
        
    }
    

}
