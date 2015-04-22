//
//  MatchDetailTableViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 20-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit


protocol Cells {
    var properties: CellProperties {get}
}


// This is an enum that holds the cell identifiers with their properties, coupled to rows and sections

enum MatchCells: Int, Cells {
    
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

// A struct that will hold all the cell properties.

struct CellProperties {
    let reuse: String
    let height: CGFloat
    
    init(reuse: String, height: CGFloat) {
        self.reuse = reuse
        self.height = height
    }
    init(_ reuse: String) {
        self.reuse = reuse
        self.height = 44
    }
}

// We create an extension of NSIndexPath to "inject" the cell identifiers to the specific indexPath which will be used by the tableview, don't forget to define a default identifier.

extension NSIndexPath {
    
    static var defaultIdentifier: Cells = MatchCells(rawValue: 0)!
    
    var cellIdentifier: Cells {
        
        get {
            let index: Int = ("\(self.section)"+"\(self.row)").toInt()!
            var _cell: Cells = NSIndexPath.defaultIdentifier
            if let c: Cells = MatchCells(rawValue: index) {
                _cell = c
            }
            return _cell
        }
    }
}


// MARK: - MatchDetailTableViewController

class MatchDetailTableViewController: UITableViewController {
    
    
    var match: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSIndexPath.defaultIdentifier = MatchCells.DetailCell
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println(self.match)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        default:
            return 4
        }
        
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cellIdentifier: MatchCells = indexPath.cellIdentifier as! MatchCells
        var reuseIdentifier: String = cellIdentifier.properties.reuse
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        // This can be encapsulated into classes, but it's not too heave
        switch cellIdentifier {

        case .HeaderCell:
        
            (cell.contentView.viewWithTag(1) as! UILabel).font = UIFont.fontAwesomeOfSize(30)
            (cell.contentView.viewWithTag(1) as! UILabel).text = String.fontAwesomeIconWithName(FontAwesome.Building)
            (cell.contentView.viewWithTag(2) as! UILabel).text = "Dit een persoon"
            //let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
            
            var imv: UIImageView = cell.contentView.viewWithTag(3) as! UIImageView
            imv.makeRound(40)
//            imv.layer.cornerRadius = 40.0
//            imv.clipsToBounds = true
//            imv.layer.frame = CGRectInset(imv.layer.frame, 20, 20)
//            imv.layer.borderColor = UIColor.whiteColor().CGColor
//            imv.layer.borderWidth = 2.0
//            if let image: UIImage = imv.image {
//                
//                image.layer
//                
//            }
            
            
        
        case .SummaryCell:
        
            cell.textLabel?.text = (self.match!.objectForKey("job") as! NSDictionary).objectForKey("title") as? String
            cell.detailTextLabel?.text = (self.match!.objectForKey("job") as! NSDictionary).objectForKey("desc") as? String

        case .DetailCell:
        
            cell.textLabel?.text = "overview"
            
        default:
            println("default")
        }
        
        return cell
    }

    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var cellIdentifier: Cells = indexPath.cellIdentifier
        return cellIdentifier.properties.height
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section > 0 {
            return createHeaderLabel("Dit is een test")
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section > 0 {
            return 25
        }
        return 0
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func createHeaderLabel(text: String) -> UIView {
        var rect: CGRect = CGRectMake(0, 0, 0, 0)
        var label: UILabel = UILabel(frame: rect)
        label.text = "Tim van Steenoven"
        label.backgroundColor = UIColor.redColor()
        label.textColor = UIColor.whiteColor()
        return label
    }
    
    func createAcceptDeclineHeaderView() -> UIView {
        
        var accept: UIButton = UIButton(frame: CGRectMake(28, 7, 150, 30))
        var decline: UIButton = UIButton(frame: CGRectMake(200, 7, 150, 30))
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

}