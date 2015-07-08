//
//  CellConfigurators.swift
//  VariableCellHeightTestProject
//
//  Created by Tim van Steenoven on 02/06/15.
//  Copyright (c) 2015 Tim van Steenoven. All rights reserved.
//

import UIKit


// When adding a new cell, add a configurator.

enum CellKey {
    case Model, Delegate, IndexPath
}

typealias CellDataType = [CellKey : Any]



// CONCRETE, downcast the cells to a specialized cell, the ABSTRACT exists in CellFactroy

class TextMessageCellConfigurator : AbstractCellConfigurator {
    
    override func configureCellText(#data: CellDataType) {
        
        let c = cell as! MessageCell

        c.leftMessageLabel.text = ""
        c.rightMessageLabel.text = ""
        
        let message: Message = data[.Model] as! Message
        
        let messageText = getSafeText(message.body)
        
        if message.role == Role.Outgoing {
            
            c.rightMessageLabel.text = messageText
            c.showOutgoingMessageView()
            
        } else {
            
            c.leftMessageLabel.text = messageText
            c.showIncommingMessageView()
        }
    }
    
    func getSafeText(text: String?) -> String {
        
        let placeHolder = "Empty message"
        if let t = text {
            if t.isEmpty {
                return placeHolder
            }
            return t
        }
        return placeHolder
    }
    
}




class UnacceptedListMessageCellConfigurator : AbstractCellConfigurator {
    
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




class SystemMessageCellConfigurator : AbstractCellConfigurator {
    
    override func configureCellText(#data: CellDataType) {

        let c = cell as! MessageSystemCell
        let message: Message = data[.Model] as! Message
        c.systemMessageLabel.text = message.body
    }
}




class OfferMessageCellConfigurator : AbstractCellConfigurator {
    
    let keyfont = UIFont.systemFontOfSize(12)
    let valfont = UIFont.systemFontOfSize(12)
    
    override func configureCell(#data: CellDataType) {
        
        let c = cell as! MessageOfferCell
        let message: Message = data[.Model] as! Message
        
        if let offer = message.offer {
            
            c.accepted = offer.acceptTalent
            c.indexPath = data[.IndexPath] as? NSIndexPath
            c.delegate = data[.Delegate] as? DilemmaCellDelegate
        }
        
        configureCellText(data: data)
    }
    
    override func configureCellText(#data: CellDataType) {
        
        let c = cell as! MessageOfferCell
        let message: Message = data[.Model] as! Message
        
        if let offer = message.offer {
        
            var points: NSAttributedString = getOfferString(offer.values!)
            let range: NSRange = NSRange(location: 0, length: points.length-1)
            points = points.attributedSubstringFromRange(range)
            
            c.messageTitle.text = getLocalizationForMessageTitle("Offer")
            c.title.text = getLocalizationForTitle(offer.name!)
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




class ContractOfferMessageCellConfigurator : AbstractCellConfigurator {
    
    override func configureCell(#data: CellDataType) {
        
        let c = cell as! MessageContractOfferCell
        let message: Message = data[.Model] as! Message

        if let offer = message.offer {

            c.indexPath = data[.IndexPath] as? NSIndexPath
            c.delegate = data[.Delegate] as? DilemmaCellDelegate
        }
    
        configureCellText(data: data)
    }
    
    override func configureCellText(#data: CellDataType) {

        let c = cell as! MessageContractOfferCell
        let message: Message = data[.Model] as! Message
        
        if let offer = message.offer {
        
            // TODO: Improve localization in switch statement
            enum User: String { case Client = "Client", Talent = "Talent" }
            func getLocalization(format: String, clientOrTalent user: User) -> String {
                let userString: String = NSLocalizedString(user.rawValue, comment: "")
                let localizedFormat: String = NSLocalizedString(format, comment: "")
                return String(format: localizedFormat, userString)
            }
            
            var isIncomming: Bool {
                return message.role == Role.Incomming ? true : false
            }
            
            if let contractState = offer.contractState {

                //println("Has contractState")
                
                var statusText: String = String()
                c.activityIndicator.startAnimating()
                
                switch contractState {
                    
                case ContractState.BothAccepted:
                    
                    c.accepted = true
                    statusText = NSLocalizedString("negotiation.state.bothaccepted", comment: "")
                    c.activityIndicator.stopAnimating()
                    
                case ContractState.NeitherDecided:
                    
                    c.enabled = true
                    c.accepted = nil
                    let who = isIncomming ? User.Client : User.Talent
                    statusText = getLocalization("negotiation.state.neitherdecided", clientOrTalent: who)
                    // If talent, set to "Client has not accepted yet" otherwise "Talent has not accepted yet"
                    
                case ContractState.ClientAccepted:
                    
                    c.enabled = true // This can set to true for both, because the buttons would go away for the other chat user
                    c.accepted = isIncomming ? nil : true
                    statusText = isIncomming ? "!!! Client has accepted" : "Talent has not accepted yet"
                    // If talent, set to "Client has accepted" otherwise if client: "Talent has not accepted yet"
                    
                case ContractState.ClientRejected:
                    
                    c.enabled = false
                    c.accepted = isIncomming ? nil : false
                    statusText = isIncomming ? "Client declined contract" : "You declined the contract"
                    c.activityIndicator.stopAnimating()
                    // Finished: If talent, set to "Client rejected" if client, set button to " You rejected"
                    
                case ContractState.TalentAccepted:
                    
                    c.enabled = true // This can set to true for both, because the buttons would go away for the other chat user
                    c.accepted = isIncomming ? true : nil
                    statusText = isIncomming ? "Client has not accepted yet" : "!!! Talent has accepted"
                    // If talent, set to "Client has not accepted yet" otherwise if client: "Talent has accepted"
                    
                case ContractState.TalentRejected:
                    
                    c.enabled = false
                    c.accepted = isIncomming ? false : nil
                    statusText = isIncomming ? "You declined the contract" : "Talent declined contract"
                    c.activityIndicator.stopAnimating()
                    // Finished: If talent, set to "You rejected" if client, set to "Talent rejected"
                }
                
                c.desc.text = "Do you want to accept the contract?"
                c.subdescription.text = statusText
            }
        }
    }
    

}




class RenegotiationRequestMessageCellConfigurator: AbstractCellConfigurator {
    
    override func configureCell(#data: CellDataType) {
        
        let c = cell as! MessageRenegotiationRequestCell
        let message: Message = data[.Model] as! Message
        
        if let offer = message.offer {
            
            c.indexPath = data[.IndexPath] as? NSIndexPath
            c.delegate = data[.Delegate] as? DilemmaCellDelegate
        }
        configureCellText(data: data)
    }
    
    override func configureCellText(#data: CellDataType) {
        
        let c = cell as! MessageRenegotiationRequestCell
        let message: Message = data[.Model] as! Message
        
        if let offer = message.offer {
            
            if offer.contractState == ContractState.BothAccepted {
                c.accepted = true
            } else if offer.contractState == ContractState.TalentRejected {
                c.accepted = false
            } else {
                c.accepted = nil
            }
        }
        
        c.title.text = NSLocalizedString("negotiations.renegotiation.title", comment: "")
    }
}


