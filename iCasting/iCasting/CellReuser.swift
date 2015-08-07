//
//  CellReuser.swift
//  VariableCellHeightTestProject
//
//  Created by Tim van Steenoven on 02/06/15.
//  Copyright (c) 2015 Tim van Steenoven. All rights reserved.
//

import UIKit

// If you make use of the CellReuser, it inherets functionality from the cell configurator. So be sure that if you get the configurator, create one first. If you don't make use of the CellReuser, it's not really worth using it.
class CellReuser {
    
    var tableView: UITableView
    var configuratorFactory: AbstractCellConfiguratorFactory
    
    init(tableView: UITableView, cellConfiguratorFactory: AbstractCellConfiguratorFactory) {
        self.tableView = tableView
        self.configuratorFactory = cellConfiguratorFactory
    }
    
    func reuseCell(cellIdentifier: CellIdentifierProtocol, indexPath: NSIndexPath, configuratorType: ConfiguratorTypeProtocol) -> UITableViewCell? {
        
        configuratorFactory.configuratorType = configuratorType
        configuratorFactory.cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier.rawValue, forIndexPath: indexPath) as? UITableViewCell
        return configuratorFactory.cell
    }
}

