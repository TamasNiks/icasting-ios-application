//
//  MatchDetailProfileTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 17/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class MatchProfileTableViewController: UITableViewController {

    var matchCard: MatchCard?
    var profileGeneral: [[String:String]]?
    //var profileHair: [String: [String:Bool]]?
    var profileNear: [[String:String]]?
    var profileLanguage: [[String:String]]?
    
    var model: Array<[[String:String]]?> = Array<[[String:String]]?>()
    var sectionTitles: Array<String> = ["Specific"]//, "Near", "Language"]
    
    override func viewDidLoad() {
        super.viewDidLoad()


        model.append(matchCard!.specific)
        
        
//        if let profileGeneral = matchCard?.profileFirstLevel {
//            model.append(profileGeneral)
//        }
        
//        if let profileHair = matchCard?.profileHair {
//            model.append(profileHair)
//        }
        
//        if let profileNear = matchCard?.profileNear {
//            model.append(profileNear)
//        }
        
//        if let profileLanguage = matchCard?.profileLanguage {
//            model.append(profileLanguage)
//        }
        
        //model = Array(profileLanguage, profileHair, profileNear, profileLanguage)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return model.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return model[section]!.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifierCell", forIndexPath: indexPath) as! UITableViewCell
        var item = model[indexPath.section]![indexPath.row]

        cell.textLabel?.text = NSLocalizedString(item.keys.first!, comment: "The text labels from a row, gotten from the JSON keys")
        cell.detailTextLabel?.text = item.values.first
        return cell
    }
    
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sectionTitles[section]
//    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createHeaderLabel(sectionTitles[section])
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    private func createHeaderLabel(text: String) -> UILabel {
        
        let label: UILabel = UILabel()
        // Define the left padding through white spaces, check https://www.cs.tut.fi/~jkorpela/chars/spaces.html
        label.text = "\u{2003}"+text
        //label.font = UIFont(name: "Open Sans", size: 10.0)
        label.backgroundColor = UIColor(red: 221/255, green: 33/255, blue: 49/255, alpha: 1)
        label.textColor = UIColor.whiteColor()
        return label
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var item = model[indexPath.section]![indexPath.row]
        let TableViewCellInset: CGFloat = 15
        let labelWidth: CGFloat = self.tableView.bounds.size.width - TableViewCellInset * 2
        let text = NSAttributedString(string: item.values.first!, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(16)])
        let options: NSStringDrawingOptions = NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading | NSStringDrawingOptions.TruncatesLastVisibleLine
        
        func rect(str: NSAttributedString) -> CGRect {
            return str.boundingRectWithSize(
                CGSizeMake(labelWidth, CGFloat.max),
                options: options,
                context: nil)
        }
        
        let boundingRectForText: CGRect = rect(text)
        return ceil(boundingRectForText.size.height) + TableViewCellInset * 2
    }


}
