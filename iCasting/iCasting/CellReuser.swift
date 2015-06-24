//
//  CellReuser.swift
//  VariableCellHeightTestProject
//
//  Created by Tim van Steenoven on 02/06/15.
//  Copyright (c) 2015 Tim van Steenoven. All rights reserved.
//

import UIKit

class CellReuser: NegotiationDetailCellConfiguratorFactory {
    
    var tableView: UITableView
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init(cellIdentifier: nil, cell: nil)
    }
    
    func reuseCell(cellIdentifier: CellIdentifier.Message, indexPath: NSIndexPath) -> UITableViewCell? {
        
        //println(cellIdentifier.rawValue)
        super.cellIdentifier = cellIdentifier
        super.cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier.rawValue, forIndexPath: indexPath) as? UITableViewCell
        return super.cell
    }
}

