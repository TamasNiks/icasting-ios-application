//
//  MatchDetailTableViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 20-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

// This is an enum that holds the cell identifiers with their properties, coupled to rows and sections. The cell type is registered with the AbstractCellsType enum placed in the ICExtension file and conforms to CellsProtocol

enum MatchCells: Int, CellsProtocol {
    
    // Define cells here with their reuseable identifiers. Use the following pattern: 0(=section)0(=row), to clarify a new section, create a case for every new section
    // Be aware to modify the structure of your model if you loop through it to prevent out of bounds errors.
    
    case HeaderCell=00, AcceptCell, SummaryCell
    case DetailCell=10
    
    // A getter for the cell properties, see the struct for details
    
    var properties: CellProperties {
        get {
            switch self {
            case .HeaderCell:
                return CellProperties(reuse: "headerCell", height: 150)
            case .SummaryCell:
                return CellProperties(reuse: "summaryCell", height: 83)
            case .AcceptCell:
                return CellProperties(reuse: "acceptCell", height: 70)
            case .DetailCell:
                return CellProperties("detailCell")
            }
        }
    }
}

// MARK: - MatchDetailTableViewController

protocol MatchDetailDelegate {
    func didRejectMatch()
    func didAcceptMatch()
}

class MatchDetailTableViewController: UITableViewController, UIScrollViewDelegate {

    struct SectionCount {
        var numberOfStaticSections: Int = 0
        var numberOfdynamicSections: Int = 0
        var sections: Int {
            return numberOfStaticSections + numberOfdynamicSections
        }
        func getDynamicSection(section: Int) -> Int {
            return section - numberOfStaticSections
        }
    }
    
    @IBOutlet weak var acceptButton: UIButton!
    
    var delegate: MatchDetailDelegate?
    var match: Match = TalentMatch()
    var sectionCount: SectionCount = SectionCount(numberOfStaticSections: 1, numberOfdynamicSections: 0)
    let rowsForStaticSection: Int = 3
    var matchDetails: MatchDetailsReturnValue?
    var avatar: UIImage?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NSIndexPath.defaultCellType = AbstractCellsType.matchCells
        NSIndexPath.defaultCellValue = MatchCells.DetailCell.rawValue
        
        self.matchDetails = self.match.getMatchDetails()
        self.sectionCount.numberOfStaticSections = 1
        self.sectionCount.numberOfdynamicSections = self.matchDetails!.details.count
        
        // Setup the seperator lines between the cell
        self.setupSeperatorLines()
        
        println(self.match.selectedMatch)
    }
    

    // Configure the scrolling behavior of the header cell
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let cell1:UITableViewCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
            if let cell2:UITableViewCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) {
                self.tableView.insertSubview(cell2, aboveSubview: cell1)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionCount.sections
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Rows for the static content in section
        if section == 0 {
            return 3
        }
        
        // Rows for dynamic section, sectionForDynamic starts at zero for the array
        var sectionForDynamic: Int = self.sectionCount.getDynamicSection(section)
        var fields:[Fields] = self.matchDetails!.details.keys.array
        var f: Fields = fields[sectionForDynamic]
        return self.matchDetails!.details[f]!.count
    }

    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier: MatchCells = indexPath.cellIdentifier as! MatchCells
        let reuseIdentifier: String = cellIdentifier.properties.reuse
        var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        self.configCell(&cell, identifier: cellIdentifier, indexPath: indexPath)
        return cell
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let cellIdentifier: CellsProtocol = indexPath.cellIdentifier
        return cellIdentifier.properties.height
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {return nil}
        var sectionForDynamic: Int = self.sectionCount.getDynamicSection(section)
        var field: Fields = self.matchDetails!.details.keys.array[sectionForDynamic]
        var label: String = field.header

        var container: UIView = UIView(frame: CGRectMake(0, 0, self.tableView.frame.width, 0))
        container.backgroundColor = UIColor.purpleColor()//UIColor(red: 213/255, green: 0, blue: 42/255, alpha: 1.0)

        var s: UIView = UIView(frame: CGRectMake(0, 0, 20, 20))
        s.backgroundColor = UIColor.redColor()

        return createHeaderLabel(label)
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section > 0 {return 30}
        return 0
    }
    
    
    // MARK: - Private functions
    
    private func configCell(inout cell: UITableViewCell, identifier: MatchCells, indexPath: NSIndexPath) {
        
        switch identifier {
            
        case .HeaderCell:
            
            (cell.contentView.viewWithTag(10) as! UILabel).font = UIFont.fontAwesomeOfSize(20)
            (cell.contentView.viewWithTag(10) as! UILabel).text = String.fontAwesomeIconWithName(FontAwesome.Building)
            (cell.contentView.viewWithTag(20) as! UILabel).font = UIFont.fontAwesomeOfSize(25)
            (cell.contentView.viewWithTag(20) as! UILabel).text = String.fontAwesomeIconWithName(FontAwesome.Male)
            
            (cell.contentView.viewWithTag(1) as! UILabel).text = matchDetails!.header[.ClientCompany] ?? "Niet ingevuld"
            (cell.contentView.viewWithTag(2) as! UILabel).text = matchDetails!.header[.ClientName] ?? "Niet ingevuld"
            //let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
            
            var imv: UIImageView = (cell.contentView.viewWithTag(3) as! UIImageView)
            var base64: String = (matchDetails!.header[.ClientAvatar] ?? "")!
            
            if let image: UIImage = ICImages.ImageWithString(base64).image {
                imv.image = image
            } else {
                imv.image = ICImages.PlaceHolderClientAvatar.image
            }
            imv.makeRound(40)
            
        case .SummaryCell:
            
            cell.textLabel?.text = matchDetails!.header[.JobTitle]!
            cell.detailTextLabel?.text = matchDetails!.header[.JobDescription]!
            
        case .AcceptCell: //Accept and Reject cell
            
            println(self.match.getStatus()?.rawValue)
            let status: FilterStatusFields? = self.match.getStatus()
            if status == .TalentAccepted || status == .Negotiations {
                let acceptBttn = (cell.contentView.viewWithTag(1) as! UIButton)
                acceptBttn.enabled = false
                acceptBttn.backgroundColor = UIColor.lightGrayColor()
                let rejectBttn = (cell.contentView.viewWithTag(2) as! UIButton)
                rejectBttn.enabled = false
                rejectBttn.backgroundColor = UIColor.lightGrayColor()
            }
            
        case .DetailCell:
            
            // Config all the normal cells
            configCell(&cell, indexPath: indexPath)

        default:
            println("no cell config")
        }
    }
    
    
    // Configuration of the default cell, this means the cell which needs to be reused many times.
    private func configCell(inout cell: UITableViewCell, indexPath: NSIndexPath) {
        
        // Measure rows for dynamic content in secion
        
        var sectionForDynamic: Int = self.sectionCount.getDynamicSection(indexPath.section)
        
        var field:Fields = self.matchDetails!.details.keys.array[sectionForDynamic]
        var sectionData = self.matchDetails!.details[field]![indexPath.row]

        //var rowData = sectionData[indexPath.row]
        var key: String = sectionData.keys.array[0]
        var placeholder: String = "-"
        if let value = sectionData[key] {
                cell.textLabel?.text = NSLocalizedString(key, comment: "The text labels from a row, gotten from the JSON keys")
                cell.detailTextLabel?.text = value ?? "found bug"
        }
        
    }
    
    
    private func createHeaderLabel(text: String) -> UILabel {
        
        let rect: CGRect = CGRectMake(0, 0, 0, 0)
        let label: UILabel = UILabel(frame: rect)
        // Define the left padding through white spaces, check https://www.cs.tut.fi/~jkorpela/chars/spaces.html
        label.text = "\u{2003}"+text
        //label.font = UIFont(name: "Open Sans", size: 10.0)
        label.backgroundColor = UIColor(white: 0.9, alpha: 1.0)//UIColor(red: 213/255, green: 0, blue: 42/255, alpha: 1.0)
        label.textColor = UIColor.darkTextColor()
        return label
    }
    
    private func setupSeperatorLines() {
        
        if self.tableView.respondsToSelector("setSeparatorInset:") {
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        if self.tableView.respondsToSelector("setLayoutMargins:") {
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
        self.tableView.layoutIfNeeded()
        
    }
    
    /*private func createAcceptDeclineHeaderView() -> UIView {
        
        let accept: UIButton = UIButton(frame: CGRectMake(28, 7, 150, 30))
        let decline: UIButton = UIButton(frame: CGRectMake(200, 7, 150, 30))
        accept.backgroundColor = UIColor.greenColor()
        decline.backgroundColor = UIColor.redColor()
        accept.setTitle("Accept", forState: UIControlState.Normal)
        decline.setTitle("Verwijder", forState: UIControlState.Normal)
        
        var hv: UIView = UIView()
        hv.backgroundColor = UIColor.whiteColor()
        hv.addSubview(accept)
        hv.addSubview(decline)

        return hv
    }*/

    // MARK: - Scroll view delegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        var ip = NSIndexPath(forRow: 0, inSection: 0)
        if let cell:UITableViewCell = self.tableView.cellForRowAtIndexPath(ip) {
            var offset:CGFloat = scrollView.bounds.origin.y / 3
            var rect: CGRect = cell.frame
            rect.origin.y = offset
            cell.frame = rect
        }
    }
    
    
    @IBAction func onAccept(sender: AnyObject) {
        println("I ACCEPT")
        
        let actionSheetController = UIAlertController(
            title: NSLocalizedString("Are you sure?", comment: ""),
            message: NSLocalizedString("AcceptMessage", comment: ""),
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let doneAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Accept", comment: ""), style: UIAlertActionStyle.Destructive)
            { (alertAction) -> Void in
            
            (self.match as! TalentMatch).accept() { possibleError in
                
                if let error = possibleError {
                    self.showErrorAlertView(error)
                } else {
                    actionSheetController.removeFromParentViewController()
                    
                    self.match.setStatus(FilterStatusFields.TalentAccepted)
                    
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                    self.delegate?.didAcceptMatch()
                }
            }
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel)
            { (alertAction) -> Void in
            actionSheetController.removeFromParentViewController()
        }
        
        actionSheetController.addAction(doneAction)
        actionSheetController.addAction(cancelAction)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    
    @IBAction func onReject(sender: AnyObject) {
        println("I REJECT")

        let actionSheetController = UIAlertController(
            title: NSLocalizedString("Are you sure?", comment: ""),
            message: NSLocalizedString("RejectMessage", comment: ""),
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let doneAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Reject", comment: ""), style: UIAlertActionStyle.Destructive)
            { (alertAction) -> Void in
            
            
            // TODO: Put model specific changes in the model class
                
            // Evoke the reject match method from the match model
            (self.match as! TalentMatch).reject() { possibleError in
                
                if let error = possibleError {
                    self.showErrorAlertView(error)
                } else {
                    actionSheetController.removeFromParentViewController()
                    
                    // Set the status and update the filter
                    //self.match.setStatus(FilterStatusFields.Closed)
                    
                    // Don't use this filter if all the closed matches are also visible in the matches overview. You will get an out of range exception. If you want to show the user all the closed matches, do this in another viewcontroller or else use the removeMatch method.
                    //self.match.filter(field: FilterStatusFields.Closed, allExcept: true, original: false)

                    self.match.removeMatch()
                    
                    self.delegate?.didRejectMatch()
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel)
            { (alertAction) -> Void in
            actionSheetController.removeFromParentViewController()
        }
        
        actionSheetController.addAction(doneAction)
        actionSheetController.addAction(cancelAction)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    
    func showErrorAlertView(error: ICErrorInfo) {
        
        let fullStr: String = error.localizedFailureReason
        let alertView = UIAlertView(
            title: NSLocalizedString("Error", comment: ""),
            message: fullStr,
            delegate: nil,
            cancelButtonTitle: nil,
            otherButtonTitles: "Ok")
        
        alertView.show()
        
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    
}