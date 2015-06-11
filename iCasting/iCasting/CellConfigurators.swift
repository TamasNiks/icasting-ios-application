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


//protocol TestProtocol {
//    
//    func testFunc<U>(model:U)
//}
//
//class BladieBla: TestProtocol {
//    func testFunc<Message>(model: Message) {
//        
//    }
//}
//
//
//class BladieBla2: TestProtocol {
//    func testFunc<CellDataType>(model: CellDataType) {
//    }
//}





// CONCRETE, downcast the cells to a specialized cell, the ABSTRACT exists in CellFactroy

class MessageCellConfigurator : CellConfigurator {
    
    override func configureCell(#data: CellDataType) {
        
        configureCellText(data: data)
    }
    
    override func configureCellText(#data: CellDataType) {
        
        var c = cell as! MessageCell

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
    
    override func configureCell(#data: CellDataType) {
        configureCellText(data: data)
    }
    
    override func configureCellText(#data: CellDataType) {
        
        let c = cell as! MessageUnacceptedCell
        
        let message: Message = data[.Model] as! Message
        
        let contract = message.contract!
        let names: [String] = contract.map { $0.name }
        let points: String = "- "+String("\n- ").join(names)
        
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
        
        if let offer = message.offer {
            
            c.accepted = offer.accepted
            c.indexPath = data[.IndexPath] as? NSIndexPath
            c.delegate = data[.Delegate] as? MessageOfferCellDelegate
        }
        
        configureCellText(data: data)
    }
    
    override func configureCellText(#data: CellDataType) {
        
        var c = cell as! MessageOfferCell
        let message: Message = data[.Model] as! Message
        
        if let offer = message.offer {
        
            let points = extractOfferValues(offer.values)

            c.messageTitle.text = getLocalizationForMessageTitle("Offer")
            c.title.text = getLocalizationForTitle(offer.name)
            c.desc.attributedText = points
        }
        
    }
    
    private func extractOfferValues(offerValues: [KeyVal]) -> NSAttributedString {
        
        var points: NSMutableAttributedString = NSMutableAttributedString()//String()
        var font = UIFont.boldSystemFontOfSize(14)
        var keyattr = [NSForegroundColorAttributeName : UIColor(white: 1/2, alpha: 1), NSFontAttributeName : font]
        var valattr = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName : font]
        
        for keyVal: KeyVal in offerValues {
            
            var name = getLocalizationForName(keyVal.key) + "\n"
            
            var key = NSMutableAttributedString(string: name, attributes: keyattr)
            points.appendAttributedString(key)
            
            var val = NSMutableAttributedString(string: ("\(keyVal.val)" + "\n"), attributes: valattr)
            points.appendAttributedString(val)
        }
        
        return points
    }
    
    private func getLocalizationForMessageTitle(title: String) -> String {
        
        var localizedTitle = NSLocalizedString(title, comment: "The title on top of an offer message")
        return localizedTitle
    }
    
    private func getLocalizationForName(name: String) -> String {
        
        var prefix = "negotiations.offer.name.%@"
        var formatted = String(format: prefix, name)
        var localizedName = NSLocalizedString(formatted, comment: "The name of an offer negotiation point.")
        return localizedName
    }
    
    private func getLocalizationForTitle(title: String) -> String {
        
        var format = "negotiations.offer.title.%@"
        var formatted = String(format: format, title)
        var localizedTitle = NSLocalizedString(formatted, comment: "")
        var localizedPostfix = NSLocalizedString("negotiations.agreement", comment: "The title of the current offer.")
        var fullTitle = localizedTitle + localizedPostfix
        return fullTitle
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


