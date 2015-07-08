//
//  AbstractCellConfigurator.swift
//  iCasting
//
//  Created by Tim van Steenoven on 07/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// INTERFACE FOR CELL CONFIGURATION

protocol CellConfiguratorProtocol {
    func configureCell(#data: CellDataType)
}



// ABSTRACT BASE CLASS

class AbstractCellConfigurator : CellConfiguratorProtocol {
    
    let cell: UITableViewCell
    
    init(cell: UITableViewCell) {
        self.cell = cell
    }
    
    func configureCell(#data: CellDataType) {
        configureCellText(data: data)
        
        /* Abstract ...  */
    }
    
    func configureCellText(#data: CellDataType) { /* Abstract ...  */ }
}




// ABSTRACT FACTORY

class CellConfiguratorFactory {
    
    var cell: UITableViewCell?
    var cellIdentifier: CellIdentifierProtocol? //CellIdentifier.Message?
    
    init(cellIdentifier: CellIdentifierProtocol?, cell: UITableViewCell?) {
        
        self.cellIdentifier = cellIdentifier
        self.cell = cell
    }
    
    func getConfigurator() -> AbstractCellConfigurator? {
        
        if let identifier = self.cellIdentifier, cell = self.cell {
            
            switch identifier.rawValue {
                
            case CellIdentifier.Message.MessageCell.rawValue:
                
                return TextMessageCellConfigurator(cell: cell)
                
            case CellIdentifier.Message.UnacceptedCell.rawValue:
                
                return UnacceptedListMessageCellConfigurator(cell: cell)
                
            case CellIdentifier.Message.SystemMessageCell.rawValue:
                
                return SystemMessageCellConfigurator(cell: cell)
                
            case CellIdentifier.Message.OfferMessageCell.rawValue:
                
                return OfferMessageCellConfigurator(cell: cell)
                
            case CellIdentifier.Message.ContractOfferMessageCell.rawValue:
                
                return ContractOfferMessageCellConfigurator(cell: cell)
                
            case CellIdentifier.Message.RenegotiationRequestMessageCell.rawValue:
                
                return RenegotiationRequestMessageCellConfigurator(cell: cell)
                
            default:
                
                return nil
            }
        }
        
        return nil
    }
}

//NegotiationDetailCellConfiguratorFactory


