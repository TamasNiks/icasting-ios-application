//
//  JobOverviewTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 26/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class JobOverviewTableViewController: ICTableViewController {

    var matchID: String?
    var sectionCount: SectionCount = SectionCount(numberOfStaticSections: 0, numberOfdynamicSections: 0)
    let rowsForStaticSection: Int = 1
    
    var job: Job!
    
    var dataSource: JobContractArray {
        return job.list ?? JobContractArray()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        if let ID = matchID {
            job = Job(matchID: ID)
            setModel(job)
            firstLoadRequest()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func requestSucceedWithModel(model: ModelRequest) -> Bool {
        
        if self.job?.list.isEmpty == false {
            println("JobOverviewTableViewController: request finnished")
            self.sectionCount.numberOfStaticSections = 1
            self.sectionCount.numberOfdynamicSections = self.dataSource.count
            return true
        }
        return false
    }
    
    
    func getModel(forIndexPath indexPath: NSIndexPath) -> [String:String] {
        
        let array = getSectionOfModel(inSection: indexPath.section)
        return array[indexPath.row]
    }
    
    override func getSectionOfModel(inSection section: Int) -> StringDictionaryArray {
     
        // Because there are more sections than in the model, we need to resolve this difference in offset
        let s = sectionCount.getDynamicSection(section)
        
        let contractTypes: [ContractType] = dataSource[s].values.first!
        
        var array = StringDictionaryArray()
        for ct in contractTypes {
            array += ct.values
        }
        return array
    }
    
    func getIdentifierForCell(indexPath: NSIndexPath) -> CellIdentifierProtocol {
        
        var identifier = indexPath.section == 0 ? CellIdentifier.JobOverview.Header : CellIdentifier.JobOverview.JobPoints
        
        let _section = sectionCount.getDynamicSection(indexPath.section)
        if indexPath.section > 0 {
            if dataSource[_section].keys.first! == MainTopic.AdditionalRequests {
                identifier = CellIdentifier.JobOverview.AdditionalRequests
            }
        }
        
        return identifier
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionCount.sections
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return rowsForStaticSection
        }
        
        // Return the number of rows in the section.
        let dict = getSectionOfModel(inSection: section)
        return dict.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier = getIdentifierForCell(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier.rawValue, forIndexPath: indexPath) as! UITableViewCell
        configureCell(cell, indexPath: indexPath, identifier: identifier)
        return cell
    }
    
    
    override func configureCell(cell: UITableViewCell, indexPath: NSIndexPath, identifier: CellIdentifierProtocol) {
        // Configure the cell...
        
        switch identifier as! CellIdentifier.JobOverview  {
            
        case .Header:
            
            cell.textLabel?.text = job.title
            cell.detailTextLabel?.text = job.description
            
        case .JobPoints:
            
            let modelForIndexPath = getModel(forIndexPath: indexPath)
            cell.textLabel?.text = modelForIndexPath.keys.first?.ICLocalizedOfferName
            cell.detailTextLabel?.text = modelForIndexPath.values.first
            
        case .AdditionalRequests:
            let modelForIndexPath = getModel(forIndexPath: indexPath)
            cell.textLabel?.text = modelForIndexPath.values.first
        }
    }
    
    

    // MARK: - Table view delegates
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let _section = sectionCount.getDynamicSection(section)
        let mainTopic = section == 0 ? MainTopic.General.rawValue : dataSource[_section].keys.first?.rawValue
        return mainTopic?.ICLocalizedNegotiationSubject
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        // Height for the Job title and description
        if indexPath.section == 0 {
            if let model = self.model {
                return tableView.calculateHeight(fromTitle: job.title, titleFontSize: 17, andDetail: job.description, detailFontSize: 13)
            }
        }

        // Height for the requests
        let model = getModel(forIndexPath: indexPath)
        if let key = model.keys.first {
            if ContractPoint.Requests.rawValue == key {
                let value = model.values.first!
                return tableView.calculateHeight(fromString: value, forFontSize: 14)
            }
        }

        // Use the standard height
        return 44
    }
    
    
    @IBAction func onDoneTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
