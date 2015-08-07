//
//  CellConfigurators.swift
//  VariableCellHeightTestProject
//
//  Created by Tim van Steenoven on 02/06/15.
//  Copyright (c) 2015 Tim van Steenoven. All rights reserved.
//

import UIKit


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
        
        if message.role == MessageRole.Outgoing {
            
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
        
            let checkMark = String.fontAwesomeIconWithName(FontAwesome.Check)+" "
            
            var isIncomming: Bool {
                return message.role == MessageRole.Incomming ? true : false
            }
            
            if let contractState = offer.contractState {
                
                var statusText: String = String()
                c.activityIndicator.startAnimating()
                
                switch contractState {
                    
                case .BothAccepted:
                    
                    c.accepted = true
                    statusText = checkMark+" "+NSLocalizedString("negotiation.state.bothaccepted", comment: "")
                    c.activityIndicator.stopAnimating()
                    
                case .NeitherDecided:
                    
                    c.enabled = true
                    c.accepted = nil
                    
                    // If talent, set to "Client has not accepted yet" otherwise "Talent has not accepted yet"
                    let who = isIncomming ? String.User.Client : String.User.Talent
                    statusText = String.getLocalization("negotiation.state.notdecided", clientOrTalent: who)
                    
                    
                case .ClientAccepted:
                    
                    c.enabled = true // This can set to true for both, because the buttons would go away for the other chat user
                    c.accepted = isIncomming ? nil : true
                    
                    // If talent, set to "Client has accepted" otherwise if client: "Talent has not decided yet"
                    let talentText = String.getLocalization("negotiation.state.notdecided", clientOrTalent: String.User.Talent)
                    let clientText = checkMark+String.getLocalization("negotiation.state.accepted", clientOrTalent: String.User.Client)
                    statusText = isIncomming ? clientText : talentText

                case .ClientRejected:
                    
                    c.enabled = false
                    c.accepted = isIncomming ? nil : false
                    
                    // If talent, set to "Client rejected" otherwise if client, set button to "You declinded contract"
                    let clientText = String.getLocalization("negotiation.state.rejected", clientOrTalent: String.User.Client)
                    let userText = String(format: NSLocalizedString("negotiation.state.rejected", comment: ""), "You")
                    statusText = isIncomming ? clientText : userText
                   
                    c.activityIndicator.stopAnimating()
                    
                case .TalentAccepted:
                    
                    c.enabled = true // This can set to true for both, because the buttons would go away for the other chat user
                    c.accepted = isIncomming ? true : nil
                    
                    // If talent, set to "Client has not accepted yet" otherwise if client: "Talent has accepted"
                    let clientText = String.getLocalization("negotiation.state.notdecided", clientOrTalent: String.User.Client)
                    let talentText = checkMark+String.getLocalization("negotiation.state.accepted", clientOrTalent: String.User.Talent)
                    statusText = isIncomming ? clientText : talentText
                    
                case .TalentRejected:
                    
                    c.enabled = false
                    c.accepted = isIncomming ? false : nil
                    
                    // Finished: If talent, set to "You rejected" if client, set to "Talent rejected"
                    let talentText = String.getLocalization("negotiation.state.rejected", clientOrTalent: String.User.Talent)
                    let userText = String(format: NSLocalizedString("negotiation.state.rejected", comment: ""), "You")
                    statusText = isIncomming ? talentText : userText
                    
                    c.activityIndicator.stopAnimating()
                    
                }
                
                c.desc.text = NSLocalizedString("negotiation.contract.desc", comment:"")
                c.subdescription.font = UIFont.fontAwesomeOfSize(14)
                c.subdescription.text = statusText
            }
        }
    }
}




class RenegotiationRequestMessageCellConfigurator: AbstractCellConfigurator {
    
    override func configureCell(#data: CellDataType) {
        
        let c = cell as! MessageDefaultDecisionCell
        let message: Message = data[.Model] as! Message
        
        if let offer = message.offer {
            
            c.indexPath = data[.IndexPath] as? NSIndexPath
            c.delegate = data[.Delegate] as? DilemmaCellDelegate
        }
        configureCellText(data: data)
    }
    
    override func configureCellText(#data: CellDataType) {
        
        let c = cell as! MessageDefaultDecisionCell
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




class ReportedCompleteMessageCellConfigurator: AbstractCellConfigurator {

    let checkMark = String.fontAwesomeIconWithName(FontAwesome.Check)+" "
    var rated: Bool?
    
    override func configureCell(#data: CellDataType) {
        
        let c = cell as! MessageDefaultDecisionCell
        let message: Message = data[.Model] as! Message
        
        if let offer = message.offer {
            c.indexPath = data[.IndexPath] as? NSIndexPath
            c.delegate = data[.Delegate] as? DilemmaCellExtendedButtonDelegate
        }
        
        configureCellText(data: data)
    }
    
    override func configureCellText(#data: CellDataType) {
        
        let c = cell as! MessageDefaultDecisionCell
        let message: Message = data[.Model] as! Message
        
        // Depending on the rated property, decide if the user can press on the button to rate, or to consider it done
        func setButtonMarkCompleted() {

            if let rated = self.rated {
                if rated ==  false {
                    c.acceptedWithButton = true
                    c.acceptedTitle = NSLocalizedString("Rate", comment:"")
                    return
                }
            }
            c.accepted = false
            c.rejectedTitle = NSLocalizedString("Completed", comment: "")
        }
        
        if let offer = message.offer {
            
            c.title.font = UIFont.fontAwesomeOfSize(12)
            
            if offer.contractState == ContractState.BothAccepted {
                setButtonMarkCompleted()
                c.title?.text = checkMark+NSLocalizedString("negotiations.reportedcomplete.bothaccepted", comment:"")
            } else if offer.contractState == ContractState.TalentAccepted {
                c.accepted = true
                c.title?.text = checkMark+String.getLocalization("negotiations.reportedcomplete.accepted", clientOrTalent: String.User.Talent)
            } else if offer.contractState == ContractState.TalentRejected {
                c.accepted = false
                c.title?.text = String.getLocalization("negotiations.reportedcomplete.rejected", clientOrTalent: String.User.Talent)
            } else if offer.contractState == ContractState.ClientAccepted {
                setButtonMarkCompleted()
                c.title?.text = checkMark+String.getLocalization("negotiations.reportedcomplete.accepted", clientOrTalent: String.User.Client)
            } else if offer.contractState == ContractState.ClientRejected {
                c.accepted = false
                c.title?.text = String.getLocalization("negotiations.reportedcomplete.rejected", clientOrTalent: String.User.Client)
                c.rejectedTitle = NSLocalizedString("Conflict", comment: "")
            } else {
                c.accepted = nil
                c.title?.text = NSLocalizedString("negotiations.reportedcomplete.title", comment: "")
            }
        }
        
        c.messageTitle?.text = NSLocalizedString("negotiations.reportedcomplete.messagetitle", comment: "")
    }
}

