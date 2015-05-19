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
    
    // SECTION 1
    case HeaderCell=00, AcceptCell, SummaryCell, ProfileCell
    
    // SECTION 2
    case DetailCell=10
    
    // A getter for the cell properties, see the struct for details
    
    var properties: CellProperties {

        switch self {
        case .HeaderCell:
            return CellProperties(reuse: "headerCell", height: 150)
        case .SummaryCell:
            return CellProperties("summaryCell") //, height: 83) //83
        case .AcceptCell:
            return CellProperties(reuse: "acceptCell", height: 70)
        case .ProfileCell:
            return CellProperties("profileCell")
        case .DetailCell:
            return CellProperties("detailCell")
        }
    }
}


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





// MARK: - MatchDetailTableViewController

class MatchDetailTableViewController: UITableViewController {

    var delegate: MatchCardDelegate?
    var matchCard: MatchCard? //= TalentMatch()
    var sectionCount: SectionCount = SectionCount(numberOfStaticSections: 1, numberOfdynamicSections: 0)
    let rowsForStaticSection: Int = 4
    var matchDetails: MatchContractType?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NSIndexPath.defaultCellType = AbstractCellsType.matchCells
        NSIndexPath.defaultCellValue = MatchCells.DetailCell.rawValue
        
        self.matchDetails = self.matchCard!.getContract()
        self.sectionCount.numberOfStaticSections = 1
        self.sectionCount.numberOfdynamicSections = self.matchDetails!.details.count
        
        // Setup the seperator lines between the cell
        self.tableView.setWholeSeperatorLines()
        
        //println(self.matchCard!.profileGeneral)
        println(self.matchCard!)
        
        //self.tableView.rowHeight = UITableViewAutomaticDimension // not actually necessary
        //self.tableView.estimatedRowHeight = 100 // turn on automatic cell variable sizing!
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

}





// MARK: - Table view data source

extension MatchDetailTableViewController {
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionCount.sections
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Rows for the static content in section
        if section == 0 {
            return rowsForStaticSection
        }
        
        // Rows for dynamic section, sectionForDynamic starts at zero for the array
        var sectionForDynamic: Int = self.sectionCount.getDynamicSection(section)
        var fields:[Fields] = self.matchDetails!.details.keys.array
        var f: Fields = fields[sectionForDynamic]
        return self.matchDetails!.details[f]!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier: MatchCells = indexPath.cellIdentifier as! MatchCells
        let reuseIdentifier: String = cellIdentifier.properties.reuse
        
        var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        self.configCell(&cell, identifier: cellIdentifier, indexPath: indexPath)
        return cell
    }
    
    
    // Private methods 
    
    private func configCell(inout cell: UITableViewCell, identifier: MatchCells, indexPath: NSIndexPath) {
        
        switch identifier {
            
        case .HeaderCell:
            (cell as! MatchHeaderCell).configureCell(matchDetails!)
        case .SummaryCell:
            cell.textLabel?.text = matchDetails!.header[.JobTitle]!
            cell.detailTextLabel?.text = matchDetails!.header[.JobDescription]!
        case .AcceptCell: //Accept and Reject cell
            (cell as! MatchAcceptCell).configureCell(matchCard!)
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
        var key: String = sectionData.keys.first!
        var placeholder: String = "-"
        
        if let value = sectionData[key] {
            cell.textLabel?.text = NSLocalizedString(key, comment: "The text labels from a row, gotten from the JSON keys")
            cell.detailTextLabel?.text = value ?? "found bug"
        }
        
    }
    
}





// MARK: - Table view delegate

extension MatchDetailTableViewController {
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let TableViewCellInset: CGFloat = 15
        
        let cellIdentifier: MatchCells = indexPath.cellIdentifier as! MatchCells
        
        if cellIdentifier == .SummaryCell {
            
            var title: String = matchDetails!.header[.JobTitle]!!
            var desc: String = matchDetails!.header[.JobDescription]!!

            let labelWidth: CGFloat = self.tableView.bounds.size.width - TableViewCellInset * 2
            
            let titleText = NSAttributedString(string: title, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(16)] )
            let detailText = NSAttributedString(string: desc, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(11)] )
            
            let options: NSStringDrawingOptions = NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading | NSStringDrawingOptions.TruncatesLastVisibleLine
            
            
            func rect(str: NSAttributedString) -> CGRect {
                return str.boundingRectWithSize(
                    CGSizeMake(labelWidth, CGFloat.max),
                    options: options,
                    context: nil)
            }
            
            let boundingRectForTitleText: CGRect = rect(titleText)
            let boundingRectForDetail: CGRect = rect(detailText)
            
            
            return ceil(boundingRectForTitleText.size.height + boundingRectForDetail.size.height) + TableViewCellInset * 2
        }
        
        return cellIdentifier.properties.height
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 { return nil }
        var sectionForDynamic: Int = self.sectionCount.getDynamicSection(section)
        var field: Fields = self.matchDetails!.details.keys.array[sectionForDynamic]
        var label: String = field.header
        
        return createHeaderLabel(label)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section > 0 {return 30}
        return 0
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    
    // Private methods 
    
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
    
}





// MARK: - IBActions

extension MatchDetailTableViewController {

    @IBAction func onAccept(sender: AnyObject) {
        println("I ACCEPT")
        
        let ac = AcceptAlertController { () -> Void in
            (self.matchCard! as! TalentMatchCard).accept() { possibleError in
                if let error = possibleError {
                    self.showErrorAlertView(error)
                } else {
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                    self.delegate?.didAcceptMatch()
                }
            }
        }.configureAlertController()
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    
    @IBAction func onReject(sender: AnyObject) {
        println("I REJECT")

        let ac = RejectAlertController { () -> Void in
            (self.matchCard! as! TalentMatchCard).reject() { possibleError in
                
                if let error = possibleError {
                    self.showErrorAlertView(error)
                } else {
                    self.delegate?.didRejectMatch()
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }.configureAlertController()
        self.presentViewController(ac, animated: true, completion: nil)
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as! MatchProfileTableViewController
        destination.matchCard = self.matchCard
    }
}




// MARK: - Scroll view delegate

extension MatchDetailTableViewController : UIScrollViewDelegate {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var ip = NSIndexPath(forRow: 0, inSection: 0)
        if let cell:UITableViewCell = self.tableView.cellForRowAtIndexPath(ip) {
            var offset:CGFloat = scrollView.bounds.origin.y / 3
            var rect: CGRect = cell.frame
            rect.origin.y = offset
            cell.frame = rect
        }
    }
    
    
}



