//
//  JobOverviewTableViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 26/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit


class JobOverviewTableViewController: UITableViewController {

    var matchID: String?
    var model: Job?
    var sectionCount: SectionCount = SectionCount(numberOfStaticSections: 0, numberOfdynamicSections: 0)
    
    var dataSource: JobContractList {
        return model?.list ?? JobContractList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        initializeModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func initializeModel() {
        
        if let ID = matchID {
            model = Job(matchID: ID)
            self.showWaitOverlay()
        }
        
        model?.get() { failure in
            self.removeAllOverlays()
            //self.messages = self.conversation!.messages
            
            if self.model?.list.isEmpty == false {
                println("JobOverviewTableViewController: request finnished")
                
                self.sectionCount.numberOfStaticSections = 1
                self.sectionCount.numberOfdynamicSections = self.dataSource.count
                
                self.tableView.reloadData()
            }
        }
    }
    
    private func getModel(forIndexPath indexPath: NSIndexPath) -> [String:String] {
        
        let array = getSectionOfModel(inSection: indexPath.section)
        return array[indexPath.row]
    }
    
    private func getSectionOfModel(inSection section: Int) -> StringDictionaryArray {
     
        // Because there are more sections than in the model, we need to resolve this difference in offset
        let _section = sectionCount.getDynamicSection(section)
        
        let contractTypes: [ContractType] = dataSource[_section].values.first!
        
        var array = StringDictionaryArray()
        for type in contractTypes {
            array += type.values
        }
        return array
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        // Return the number of sections.
        return sectionCount.sections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return 1
        }
        
        // Return the number of rows in the section.
        let dict = getSectionOfModel(inSection: section)
        return section == 0 ? 1 : dict.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier = indexPath.section == 0 ? CellIdentifier.JobOverview.Header : CellIdentifier.JobOverview.JobPoints
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier.rawValue, forIndexPath: indexPath) as! UITableViewCell

        
        // Configure the cell...
        
        switch identifier {
            
        case .Header:
    
            cell.textLabel!.text = model?.title
            cell.detailTextLabel!.text = model?.description
            
        case .JobPoints:

            let modelForIndexPath = getModel(forIndexPath: indexPath)
            cell.textLabel!.text = modelForIndexPath.keys.first?.ICLocalizedOfferName
            cell.detailTextLabel!.text = modelForIndexPath.values.first
            
        }
    
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let _section = sectionCount.getDynamicSection(section)
        return section == 0 ? nil : dataSource[_section].keys.first?.rawValue.ICLocalizedNegotiationSubject
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if indexPath.section == 0 {
            if let model = model {
                return self.tableView.calculateHeight(fromTitle: model.title, andDetail: model.description)
            }
        }
        else {
            let key = getModel(forIndexPath: indexPath).keys.first!
            if key == ContractPoint.Requests.rawValue {
                let value = getModel(forIndexPath: indexPath).values.first!
                return self.tableView.calculateHeight(fromString: value, forFontSize: 12)
            }
        }
        
        return 44
    }
}
