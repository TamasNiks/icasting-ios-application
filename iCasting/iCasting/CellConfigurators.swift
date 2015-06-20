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



// ABSTRACT FACTORY

class NegotiationDetailCellConfiguratorFactory {
    
    var cell: UITableViewCell?
    var cellIdentifier: CellIdentifier?
    
    init(cellIdentifier: CellIdentifier?, cell: UITableViewCell?) {
        
        self.cellIdentifier = cellIdentifier
        self.cell = cell
    }
    
    func getConfigurator() -> CellConfigurator? {
        
        if let identifier = self.cellIdentifier, cell = self.cell {
            
            switch identifier {
                
            case CellIdentifier.MessageCell:
                
                return MessageCellConfigurator(cell: cell)
                
            case CellIdentifier.UnacceptedCell:
                
                return UnacceptedListMessageCellConfigurator(cell: cell)
                
            case CellIdentifier.GeneralSystemMessageCell:
                
                return SystemMessageCellConfigurator(cell: cell)
                
            case CellIdentifier.OfferMessageCell:
                
                return OfferMessageCellConfigurator(cell: cell)
                
            default:
                
                return DefaultCellConfigurator(cell: cell)
            }
        }
        
        return nil
    }
}



// INTERFACE FOR CELL CONFIGURATION

protocol CellConfigProtocol {
    func configureCell(#data: CellDataType)
}



// ABSTRACT BASE CLASS

class CellConfigurator : CellConfigProtocol {
    
    let cell: UITableViewCell
    
    init(cell: UITableViewCell) {
        self.cell = cell
    }
    
    init(cell: MessageCell) {
        self.cell = cell
    }
    
    func configureCell(#data: CellDataType) {
        configureCellText(data: data)
        
        /* Abstract ...  */
    }
    
    func configureCellText(#data: CellDataType) { /* Abstract ...  */ }
    
}





// CONCRETE, downcast the cells to a specialized cell, the ABSTRACT exists in CellFactroy

class MessageCellConfigurator : CellConfigurator {
    
    override func configureCellText(#data: CellDataType) {
        
        let c = cell as! MessageCell

        c.leftMessageLabel.text = ""
        c.rightMessageLabel.text = ""
        
        let message: Message = data[.Model] as! Message
        if message.role == Role.Outgoing {
         
            c.rightMessageLabel.text = message.body
            c.showOutgoingMessageView()
            
        } else {
            
            c.leftMessageLabel.text = message.body
            c.showIncommingMessageView()
        }
    }
}



class UnacceptedListMessageCellConfigurator : CellConfigurator {
    
    override func configureCellText(#data: CellDataType) {
        
        let c = cell as! MessageUnacceptedCell
        
        let message: Message = data[.Model] as! Message
        
        let contract = message.contract!
        let names: [String] = contract.map { $0.name }
        let points: String = "- "+String("\n- ").join(names)
        //println(points)
        c.systemMessageLabel.text = message.body
        c.unacceptedPointsLabel.text = points
    }
}



class SystemMessageCellConfigurator : CellConfigurator {
    
    override func configureCellText(#data: CellDataType) {

        let c = cell as! MessageSystemCell
        let message: Message = data[.Model] as! Message
        c.systemMessageLabel.text = message.body
    }
}



class OfferMessageCellConfigurator : CellConfigurator {
    
    let keyfont = UIFont.systemFontOfSize(12)
    let valfont = UIFont.systemFontOfSize(12)
    
    override func configureCell(#data: CellDataType) {
        
        let c = cell as! MessageOfferCell
        let message: Message = data[.Model] as! Message
        
        if let offer = message.offer {
            
            c.accepted = offer.accepted
            c.indexPath = data[.IndexPath] as? NSIndexPath
            c.delegate = data[.Delegate] as? MessageOfferCellDelegate
        }
        
        configureCellText(data: data)
    }
    
    override func configureCellText(#data: CellDataType) {
        
        let c = cell as! MessageOfferCell
        let message: Message = data[.Model] as! Message
        
        if let offer = message.offer {
        
            
            var points: NSAttributedString = getOfferString(offer.values)
            let range: NSRange = NSRange(location: 0, length: points.length-1)
            points = points.attributedSubstringFromRange(range)
            
            c.messageTitle.text = getLocalizationForMessageTitle("Offer")
            c.title.text = getLocalizationForTitle(offer.name)
            c.desc.attributedText = points
        }
        
    }
    
    private func getOfferString(offerValues: [KeyVal]) -> NSMutableAttributedString {
        
        let keyattr = [NSForegroundColorAttributeName : UIColor(white: 1/1.65, alpha: 1), NSFontAttributeName : keyfont]
        let valattr = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName : valfont]
        
        var points: NSMutableAttributedString = NSMutableAttributedString()
        
        for keyVal: KeyVal in offerValues {
            
            let name = getLocalizationForName(keyVal.key) + "\n"
            let key = NSMutableAttributedString(string: name, attributes: keyattr)
            points.appendAttributedString(key)
            
            let val = keyVal.val
            var valStr: NSMutableAttributedString = NSMutableAttributedString()
            
            if val is [KeyVal] {
                valStr = getOfferString(val as! [KeyVal])
            } else {
                valStr = NSMutableAttributedString(string: ("\(keyVal.val)" + "\n"), attributes: valattr)
            }
            points.appendAttributedString(valStr)
        }
        
        return points
    }
    
    
    private func getLocalizationForMessageTitle(title: String) -> String {
        
        let localizedTitle = NSLocalizedString(title, comment: "The title on top of an offer message")
        return localizedTitle
    }
    
    private func getLocalizationForName(name: String) -> String {
        
        let format = "negotiations.offer.name.%@"
        let formatted = String(format: format, name)
        let localizedName = NSLocalizedString(formatted, comment: "The name of an offer negotiation point.")
        return localizedName
    }
    
    private func getLocalizationForTitle(title: String) -> String {
        
        let format = "negotiations.offer.title.%@"
        let formatted = String(format: format, title)
        let localizedTitle = NSLocalizedString(formatted, comment: "")
        let localizedPostfix = NSLocalizedString("negotiations.agreement", comment: "The title of the current offer.")
        let fullTitle = localizedTitle + " " + localizedPostfix
        return fullTitle
    }
}



class DefaultCellConfigurator: CellConfigurator {
    
    override func configureCellText(#data: CellDataType) {
        cell.textLabel?.text = data[CellKey.Title] as? String
        cell.detailTextLabel?.text = data[CellKey.Description] as? String
    }
    
}

