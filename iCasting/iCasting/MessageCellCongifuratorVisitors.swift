//
//  CellCongifuratorVisitors.swift
//  iCasting
//
//  Created by Tim van Steenoven on 15/06/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// EXPERIMENT

protocol CellVisitorAcceptProtocol {
    func accept(configurator: MessageCellCongifuratorVisitors)
}

protocol MessageCellCongifuratorVisitors {
    
    func visit(cell: MessageCell)
    func visit(cell: MessageSystemCell)
    func visit(cell: MessageUnacceptedCell)
    func visit(cell: MessageOfferCell)
}


class ConcreteMessageCellCongifuratorVisitors: MessageCellCongifuratorVisitors {
    
    var data: CellDataType
    
    init(data: CellDataType) {
        self.data = data
    }
    
    func visit(cell: MessageCell) {
        
        var oc: AbstractCellConfigurator = TextMessageCellConfigurator(cell: cell)
        oc.configureCell(data: data)
    }
    
    
    func visit(cell: MessageSystemCell) {
        
        var oc: AbstractCellConfigurator = SystemMessageCellConfigurator(cell: cell)
        oc.configureCell(data: data)
    }
    
    
    func visit(cell: MessageUnacceptedCell) {
        
        var oc: AbstractCellConfigurator = UnacceptedListMessageCellConfigurator(cell: cell)
        oc.configureCell(data: data)
    }
    
    
    func visit(cell: MessageOfferCell) {
        
        var oc: AbstractCellConfigurator = OfferMessageCellConfigurator(cell: cell)
        oc.configureCell(data: data)
    }
}
