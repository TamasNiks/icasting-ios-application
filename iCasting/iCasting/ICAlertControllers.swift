//
//  FilterMatchAlertController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 16/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

protocol ICAlertController {
    func configureAlertController() -> UIAlertController
}

class AcceptAlertController : ICAlertController {
    
    private let alertController: UIAlertController
    let postAction: ()->Void
    
    init(postAction: () -> Void) {
        self.postAction = postAction
       
        self.alertController = UIAlertController(
            title: NSLocalizedString("Are you sure?", comment: ""),
            message: NSLocalizedString("AcceptMessage", comment: ""),
            preferredStyle: UIAlertControllerStyle.ActionSheet)
    }
    
    func configureAlertController() -> UIAlertController {
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Accept", comment: ""),
            style: UIAlertActionStyle.Destructive) { (alertAction) -> Void in
                self.postAction()
        })
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
            style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
        }))
        return alertController
    }
}


class RejectAlertController : ICAlertController {
    
    private let alertController: UIAlertController
    let postAction: ()->Void
    
    init(postAction: () -> Void) {
        self.postAction = postAction
        
        self.alertController = UIAlertController(
            title: NSLocalizedString("Are you sure?", comment: ""),
            message: NSLocalizedString("RejectMessage", comment: ""),
            preferredStyle: UIAlertControllerStyle.ActionSheet)
    }
    
    func configureAlertController() -> UIAlertController {
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Reject", comment: ""),
            style: UIAlertActionStyle.Destructive) { (alertAction) -> Void in
                self.postAction()
            })
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
            style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
        }))
        return alertController
    }
}


class FilterMatchAlertController : ICAlertController {

    private let alertController: UIAlertController
    let postAction: ()->Void
    
    let match: Match
    
    init(resource: Match, postAction: () -> Void) {
        self.match = resource
        self.postAction = postAction
        
        self.alertController = UIAlertController(
            title: NSLocalizedString("matches.filter.actionsheet.title", comment: "Title of the actionsheet"),
            message: NSLocalizedString("matches.filter.actionsheet.message", comment: "Subtext of the actionsheet"),
            preferredStyle: UIAlertControllerStyle.ActionSheet)
    }
    
    
    func configureAlertController() -> UIAlertController {
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("ActiveFilter", comment: "Filter matches"),
            style: UIAlertActionStyle.Default) { (action) -> Void in
                self.match.filter(field: FilterStatusFields.Closed, allExcept: true)
                self.postAction()              
            })
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("UnansweredFilter", comment: "Filter matches"),
            style: UIAlertActionStyle.Default) { (action) -> Void in
                self.match.filter(field: FilterStatusFields.Pending, allExcept: false)
                self.postAction()
                
            })
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("PendingClientFilter", comment: "Filter matches"),
            style: UIAlertActionStyle.Default) { (action) -> Void in
                self.match.filter(field: FilterStatusFields.TalentAccepted, allExcept: false)
                self.postAction()
                
            })
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("NegotiationFilter", comment: "Filter matches"),
            style: UIAlertActionStyle.Default) { (action) -> Void in
                self.match.filter(field: FilterStatusFields.Negotiations, allExcept: false)
                self.postAction()
                
            })

        alertController.addAction(UIAlertAction(title: NSLocalizedString("FinishedFilter", comment: "Filter matches"),
            style: UIAlertActionStyle.Default) { (action) -> Void in
                self.match.filter(field: FilterStatusFields.Completed, allExcept: false)
                self.postAction()
                
            })
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("ClosedFilter", comment: "Filter matches"),
            style: UIAlertActionStyle.Default) { (action) -> Void in
                self.match.filter(field: FilterStatusFields.Closed, allExcept: false)
                self.postAction()
                
            })
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
            style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            
        }))
        
        // Add more alert actions filters here...
    
        return alertController
    }
    
}

