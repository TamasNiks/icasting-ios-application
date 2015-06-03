//
//  CellMediator.swift
//  VariableCellHeightTestProject
//
//  Created by Tim van Steenoven on 02/06/15.
//  Copyright (c) 2015 Tim van Steenoven. All rights reserved.
//

import UIKit

class CellReuseFactory {
    
    var tableView: UITableView
    
    var cell: UITableViewCell?
    var cellIdentifier: CellIdentifier?
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    func reuseCell(cellIdentifier: CellIdentifier, indexPath: NSIndexPath) -> UITableViewCell {
        
        println(cellIdentifier.rawValue)
        self.cellIdentifier = cellIdentifier
        self.cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier.rawValue, forIndexPath: indexPath) as? UITableViewCell
        return cell!
    }
    
}


class NegotiationDetailCellConfigurationFactory: CellReuseFactory {
    
    func getConfigurator() -> CellConfigurator? {
        
        if let identifier = super.cellIdentifier {
        
            switch identifier {
                
            case CellIdentifier.MessageCell:
                
                return MessageCellConfigurator(cell: cell!)
                
            case CellIdentifier.UnacceptedCell:
                
                return UnacceptedListMessageCellConfigurator(cell: cell!)
                
            case CellIdentifier.GeneralSystemMessageCell:
                
                return SystemMessageCellConfigurator(cell: cell!)
                
            case CellIdentifier.OfferMessageCell:
            
                return OfferMessageCellConfigurator(cell: cell!)
                
            default:
                
                return DefaultCellConfigurator(cell: cell!)
            }
        }
    
        return nil
    }
}

