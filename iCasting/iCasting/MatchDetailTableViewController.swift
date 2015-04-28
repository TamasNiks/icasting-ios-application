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
    
    // Define cells here with their reuseable identifiers. Use the following pattern: 0(section)0(row), create a case for
    // every new section
    
    case HeaderCell=00, SummaryCell, AcceptCell
    case DetailCell=10
    
    // A getter for the cell properties, see the struct for details
    
    var properties: CellProperties {
        get {
            switch self {
            case .HeaderCell:
                return CellProperties(reuse: "headerCell", height: 140)
            case .SummaryCell:
                return CellProperties("summaryCell")
            case .AcceptCell:
                return CellProperties("acceptCell")
            case .DetailCell:
                return CellProperties("detailCell")
            }
        }
    }
}

// MARK: - MatchDetailTableViewController

class MatchDetailTableViewController: UITableViewController {

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
    
    var match: Match = Match()
    var sectionCount: SectionCount = SectionCount(numberOfStaticSections: 1, numberOfdynamicSections: 0)
    
    let rowsForStaticSection: Int = 3
    //let sectionFields: [String] = ["Vergoeding", "Afkoop", "Tijd", "Locatie"]
    
    var matchDetails: MatchDetailsReturnValue?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NSIndexPath.defaultCellType = AbstractCellsType.matchCells
        NSIndexPath.defaultCellValue = MatchCells.DetailCell.rawValue
        
        self.matchDetails = self.match.getMatchDetails()
    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.tableView.reloadData()
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
        return 1
        // Measure rows for dynamic content in secion
//        var sectionForDynamic: Int = section - staticSectionAmount
//        var values: NSArray = self.final.allValues
//        var obj: AnyObject = values[sectionForDynamic]
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
        var label: String = "lala"
        return createHeaderLabel(label)
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section > 0 {return 25}
        return 0
    }
    
    
    
    
    
    // MARK: - PRIVATE FUNCTIONS
    
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
            
            var imv: UIImageView = cell.contentView.viewWithTag(3) as! UIImageView
            imv.makeRound(40)
            
        case .SummaryCell:
            
            cell.textLabel?.text = matchDetails!.header[.JobTitle]!
            cell.detailTextLabel?.text = matchDetails!.header[.JobDescription]!
            
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
        cell.textLabel?.text = "txt"
    }
    
    
    private func createHeaderLabel(text: String) -> UIView {
        let rect: CGRect = CGRectMake(0, 0, 0, 0)
        let label: UILabel = UILabel(frame: rect)
        label.text = text
        label.backgroundColor = UIColor.redColor()
        label.textColor = UIColor.whiteColor()
        return label
    }
    
    
    private func createAcceptDeclineHeaderView() -> UIView {
        
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
    }

    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func onAccept(sender: AnyObject) {
        println("I ACCEPT")
    }
    
    
    @IBAction func onReject(sender: AnyObject) {
        println("I REJECT")
    }
    
    
}