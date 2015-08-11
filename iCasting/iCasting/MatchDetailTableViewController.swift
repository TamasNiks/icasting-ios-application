//
//  MatchDetailTableViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 20-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit



class MatchDetailTableViewController: ICTableViewController {

    weak var delegate: MatchCardObserver?
    var ratingController: RatingController!
    var matchCard: MatchCard! //= TalentMatch()
    var sectionCount: SectionCount = SectionCount(numberOfStaticSections: 1, numberOfdynamicSections: 0)
    let rowsForStaticSection: Int = 4
    var matchDetails: MatchDetailType?
    
    
    // MARK: - ViewController Life cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        prepareViewController()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Configure the scrolling behavior of the header cell
        if let cell1:UITableViewCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
            if let cell2:UITableViewCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) {
                tableView.insertSubview(cell2, aboveSubview: cell1)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func prepareViewController() {
        
        NSIndexPath.defaultCellPropertyType = AbstractCellProperty.MatchDetailCells
        NSIndexPath.defaultCellIndex = 10
        
        ratingController = RatingController(viewController: self)
        
        matchDetails = matchCard?.getOverview()
        
        sectionCount.numberOfStaticSections = 1
        
        if let matchDetails = self.matchDetails {
            sectionCount.numberOfdynamicSections = matchDetails.details.count
        }
        
        // Setup the seperator lines between the cell
        tableView.setWholeSeperatorLines()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? MatchProfileTableViewController {
            destination.matchCard = self.matchCard
        }
        
        if let destination = segue.destinationViewController as? ConversationViewController {
            destination.matchID = self.matchCard?.getID(FieldID.MatchCardID)
            destination.matchCard = self.matchCard
        }
        
        if let destination = segue.destinationViewController as? ClientProfileTableViewController {
            destination.matchID = self.matchCard?.getID(FieldID.MatchCardID)
        }
    }
    
    
    // Data source helper methods
    
    func getModel(forIndexPath indexPath: NSIndexPath) -> [String:String] {
        
        let array = getSectionOfModel(inSection: indexPath.section)
        return array[indexPath.row]
    }
    
    override func getSectionOfModel(inSection section: Int) -> StringDictionaryArray {
        
        // Rows for dynamic section, sectionForDynamic starts at zero for the array
        let sectionForDynamic: Int = sectionCount.getDynamicSection(section)
        let fields: [Fields] = matchDetails!.details.keys.array
        let f: Fields = fields[sectionForDynamic]
        return matchDetails!.details[f]!
    }
    
    
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionCount.sections
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Rows for the static content in section
        if section == 0 {
            return rowsForStaticSection
        }
        
        // Return the number of rows in the section.
        let dict = getSectionOfModel(inSection: section)
        return dict.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = indexPath.cellIdentifier
        let reuseIdentifier: String = cellIdentifier.properties.reuse
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        configureCell(cell, indexPath: indexPath, identifier: cellIdentifier)
        
        return cell
    }
    
    override func configureCell(cell: UITableViewCell, indexPath: NSIndexPath, identifier: CellIdentifierProtocol) {
        
        if let c = cell as? MatchHeaderCell {
            
            c.configureCell(matchDetails!)
            
        } else if let c = cell as? MatchSummaryCell {
            
            c.configureCell(matchDetails!)
            
        } else if let c = cell as? MatchDecisionCell {
            
            c.delegate = self
            c.indexPath = indexPath
            c.configureCell(matchCard!)
            
        } else if let c = cell as? MatchDefaultCell {
            
            //let dict = getSectionOfModel(inSection: indexPath.section)
            let rowValue = getModel(forIndexPath: indexPath) //dict[indexPath.row]
            c.configureCell(rowValue)
            
        } else {
            
            println("no cell config for id: ")
            println(identifier.rawValue)
        }
    }
}





// MARK: - Table view delegate

extension MatchDetailTableViewController {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let cellIdentifier = indexPath.cellIdentifier
        
        if cellIdentifier.rawValue == CellIdentifier.MatchDetail.Summary.rawValue {

            var title: String = matchDetails!.general[.JobTitle]!!
            var desc: String = matchDetails!.general[.JobDescLong]!!
            return self.tableView.calculateHeight(fromTitle: title, titleFontSize: 16, andDetail: desc, detailFontSize: 11)
        }
        
        return cellIdentifier.properties.height
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return nil
        }
        
        let sectionForDynamic: Int = self.sectionCount.getDynamicSection(section)
        let field: Fields = self.matchDetails!.details.keys.array[sectionForDynamic]
        let label: String = field.header
        return createHeaderLabel(label)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section > 0 {
            return 30
        }
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





// MARK: - Dilemma Cell Extended Button Delegate

extension MatchDetailTableViewController: DilemmaCellExtendedButtonDelegate {

    func dilemmaCell(
        cell: UITableViewCell,
        didPressButtonForState decisionState: DecisionState,
        forIndexPath indexPath: NSIndexPath,
        startAnimation: () -> ()) {
        
            println("Dilemma cell delegate")
            
            if User.sharedInstance.mailIsVerified == false {
                
                let errorInfo = ICError.CustomErrorInfoType.EmailNotVerifiedError.errorInfo
                ICAlertControllerTest.showEmailVerificationAlert(errorInfo, viewController: self)
                
            } else {
            
                var ac: UIAlertController
                
                switch decisionState {
                    
                case DecisionState.Accept:
                    
                    ac = AcceptAlertController { () in
                        self.handleDecision(decisionState, startAnimation: startAnimation)
                    }.configureAlertController()
                    
                case DecisionState.Reject:
                    
                    ac = RejectAlertController { () in
                        self.handleDecision(decisionState, startAnimation: startAnimation)
                    }.configureAlertController()
                }
                
                self.presentViewController(ac, animated: true, completion: nil)
            }
    }
    

    func dilemmaCell(cell: UITableViewCell, didPressDecidedButtonForState decidedState: DecisionState, forIndexPath indexPath: NSIndexPath) {

        if let mc = self.matchCard, status = mc.getStatus()  {

            let conditions = status == FilterStatusFields.Negotiations || status == FilterStatusFields.Completed && mc.talentHasRated == false
            
            if conditions {
                
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                performSegueWithIdentifier(SegueIdentifier.Conversation, sender: nil)
            }
        }
    }
    
    
    func handleDecision(decisionState: DecisionState, startAnimation: () -> ()) {
        
        self.matchCard?.postDecision(decisionState, callBack: { (error) -> () in
            if let error = error {
                super.performErrorHandling(error)
                return
            }
            startAnimation()
            switch decisionState {
                
            case DecisionState.Accept:
                
                self.delegate?.didAcceptMatch()
                
            case DecisionState.Reject:
                
                self.navigationController?.popViewControllerAnimated(true)
                self.delegate?.didRejectMatch()
                
            }
        })
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



