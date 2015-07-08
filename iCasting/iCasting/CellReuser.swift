//
//  CellReuser.swift
//  VariableCellHeightTestProject
//
//  Created by Tim van Steenoven on 02/06/15.
//  Copyright (c) 2015 Tim van Steenoven. All rights reserved.
//

import UIKit

// If you make use of the CellReuser, it inherets functionality from the cell configurator. So be sure that if you get the configurator, create one first
class CellReuser: CellConfiguratorFactory {
    
    var tableView: UITableView
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init(cellIdentifier: nil, cell: nil)
    }
    
    func reuseCell(cellIdentifier: CellIdentifierProtocol, indexPath: NSIndexPath) -> UITableViewCell? {
        
        super.cellIdentifier = cellIdentifier
        super.cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier.rawValue, forIndexPath: indexPath) as? UITableViewCell
        return super.cell
    }
}

