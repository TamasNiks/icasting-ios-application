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


protocol ConfiguratorTypeProtocol {
    var rawValue: String { get }
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

protocol CellConfiguratorFactoryProtocol {
    func getConfigurator() -> AbstractCellConfigurator?
}


class AbstractCellConfiguratorFactory: CellConfiguratorFactoryProtocol {

    var cell: UITableViewCell?
    var configuratorType: ConfiguratorTypeProtocol? //CellIdentifier.Message?
    
    init() {}
    
    init(configuratorType: ConfiguratorTypeProtocol?, cell: UITableViewCell?) {
        
        self.configuratorType = configuratorType
        self.cell = cell
    }

    // Override this method...
    func getConfigurator() -> AbstractCellConfigurator? {
        return nil
    }
}


class MessageCellConfiguratorFactory: AbstractCellConfiguratorFactory {
    
    override func getConfigurator() -> AbstractCellConfigurator? {
    
        if let cell = self.cell, let configuratorType = configuratorType as? TextType {
            
            switch configuratorType {
                
            case TextType.Text:
                return TextMessageCellConfigurator(cell: cell)
            case TextType.SystemText:
                return SystemMessageCellConfigurator(cell: cell)
            case TextType.Offer:
                return OfferMessageCellConfigurator(cell: cell)
            case TextType.ContractOffer:
                return ContractOfferMessageCellConfigurator(cell: cell)
            case TextType.RenegotationRequest:
                return RenegotiationRequestMessageCellConfigurator(cell: cell)
            case TextType.SystemContractUnaccepted:
                return UnacceptedListMessageCellConfigurator(cell: cell)
            case TextType.ReportedComplete:
                return ReportedCompleteMessageCellConfigurator(cell: cell)
            }
        }
        
        return nil
    }
}




