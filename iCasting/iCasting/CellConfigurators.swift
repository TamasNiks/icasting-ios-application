//
//  CellConfigurators.swift
//  VariableCellHeightTestProject
//
//  Created by Tim van Steenoven on 02/06/15.
//  Copyright (c) 2015 Tim van Steenoven. All rights reserved.
//

import UIKit


// When adding a new cell, add a configurator which will act as a mediator. Use as much as possible the existing values of CellKeys.

enum CellKey {
    case Model
    case Title, Description
    case Delegate, IndexPath
    case LeftMessage, RightMessage
    case MessageTitle
}

typealias CellDataType = [CellKey : Any]

protocol CellConfigProtocol {
    func configureCell(#data: CellDataType)
}



// ABSTRACT

class CellConfigurator : CellConfigProtocol {
    
    var cell: UITableViewCell
    
    init(cell: UITableViewCell) {
        self.cell = cell
    }
    
    func configureCell(#data: CellDataType) { /* Abstract ...  */ }
    func configureCellText(#data: CellDataType) { /* Abstract ...  */ }
    
}



// CONCRETE, downcast the cells to a specialized cell, the ABSTRACT exists in CellFactroy

class MessageCellConfigurator : CellConfigurator {
    
    override func configureCell(#data: CellDataType) {
        
        configureCellText(data: data)
    }
    
    override func configureCellText(#data: CellDataType) {
        
        var c = cell as! MessageCell
        
        let message: Message = data[.Model] as! Message
        if message.role == Role.User {
            
            c.leftMessageLabel.text = "Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Integer posuere erat a ante venenatis dapibus posuere velit aliquet."//message.body
            c.rightMessageLabel.hidden = true
        } else {
            c.rightMessageLabel.text = "Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Integer posuere erat a ante venenatis dapibus posuere velit aliquet."//message.body
            c.leftMessageLabel.hidden = true
        }
    }
}





class UnacceptedListMessageCellConfigurator : CellConfigurator {
    
    override func configureCell(#data: CellDataType) {
        configureCellText(data: data)
    }
    
    override func configureCellText(#data: CellDataType) {
        var c = cell as! MessageUnacceptedCell
        
        let message: Message = data[.Model] as! Message
        
        let contract = message.getContractValues()
        let names: [String] = contract.map { $0.name }
        let points: String = "Nulla vitae elit libero, a pharetra augue. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Etiam porta sem malesuada magna mollis euismod."//String("\n ").join(names)
        
        c.systemMessageLabel.text = message.body
        c.unacceptedPointsLabel.text = points
    }
}





class SystemMessageCellConfigurator : CellConfigurator {
    
    override func configureCell(#data: CellDataType) {
        configureCellText(data: data)
    }
    
    override func configureCellText(#data: CellDataType) {
        var c = cell as! MessageSystemCell
        c.systemMessageLabel.text = data[.Description] as? String
    }
}





class OfferMessageCellConfigurator : CellConfigurator {
    
    override func configureCell(#data: CellDataType) {
        
        var c = cell as! MessageOfferCell
        let message: Message = data[.Model] as! Message
        
        if let offer = message.getOffer() {
            
            c.accepted = offer.accepted
            c.indexPath = data[.IndexPath] as? NSIndexPath
            c.delegate = data[.Delegate] as? MessageOfferCellDelegate
        }
        
        configureCellText(data: data)
    }
    
    override func configureCellText(#data: CellDataType) {
        
        var c = cell as! MessageOfferCell
        let message: Message = data[.Model] as! Message
        
        if let offer = message.getOffer() {
        
            var values: String = String()
            for keyVal: KeyVal in offer.values {
                values += (keyVal.key + "\n")
            }
            
            c.messageTitle.text = NSLocalizedString("Offer", comment: "")
            c.title.text = offer.name
            c.desc.text = values
        }
        
    }
}





class DefaultCellConfigurator: CellConfigurator {
    
    override func configureCell(#data: CellDataType) {
        configureCellText(data: data)
    }
    
    override func configureCellText(#data: CellDataType) {
        cell.textLabel?.text = data[CellKey.Title] as? String
        cell.detailTextLabel?.text = data[CellKey.Description] as? String
    }
    
}
