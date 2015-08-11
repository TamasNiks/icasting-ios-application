//
//  ICAlertController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 11/08/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


private let alertControllerTitle = NSLocalizedString("Announcement", comment: "Title of alert")
private let actionCancelTitle = NSLocalizedString("Cancel", comment: "Title of action")
private let actionContinueTitle = NSLocalizedString("Continue", comment: "Title of action")

class ICAlertControllerTest {

    typealias HandlerClosure = ()->Void
    
    static func showGeneralErrorAlert(errorInfo: ICErrorInfo, viewController vc: UIViewController, cancelHandler: HandlerClosure? = nil) {
        
        let message = errorInfo.localizedDescription
        let ac = UIAlertController(title: alertControllerTitle, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: actionCancelTitle, style: UIAlertActionStyle.Cancel) { action in cancelHandler?() })
        vc.presentViewController(ac, animated: true, completion: nil)
    }
    
    
    static func showGeneralAlert(message: String, viewController vc: UIViewController) {
        
        let ac = UIAlertController(title: alertControllerTitle, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: actionCancelTitle, style: UIAlertActionStyle.Cancel) { action in })
        vc.presentViewController(ac, animated: true, completion: nil)
    }
    
    
    static func showGeneralSuccessAlert(message: String, viewController vc: UIViewController, continueHandler: HandlerClosure? = nil) {
    
        let ac = UIAlertController(title: "Success", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { action in })
        
        if let handler = continueHandler {
            ac.addAction(UIAlertAction(title: actionContinueTitle, style: UIAlertActionStyle.Default) { action in handler() })
        }
        
        vc.presentViewController(ac, animated: true, completion: nil)
    }
    
    
    static func showEmailVerificationAlert(
        errorInfo: ICErrorInfo,
        viewController vc: UIViewController,
        continueHandler: HandlerClosure? = nil,
        cancelHandler: HandlerClosure? = nil) {
        
        let message = errorInfo.localizedDescription
        
        let ac = UIAlertController(title: alertControllerTitle, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Actions
        let actionTitle = NSLocalizedString("alert.user.resendverificationmail", comment: "")
        ac.addAction(UIAlertAction(title: actionCancelTitle, style: UIAlertActionStyle.Cancel) { action in cancelHandler?() })
        ac.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Destructive) { [weak vc] action in
            
            vc?.showWaitOverlay()
            User.sharedInstance.verifyMail() { [weak vc] failure in
                vc?.removeAllOverlays()
                if let failure = failure {
                    ICAlertControllerTest.showGeneralErrorAlert(failure, viewController: vc!, cancelHandler: cancelHandler)
                } else {
                    let localizedMessage = NSLocalizedString("alert.user.emailverificationsend", comment: "")
                    ICAlertControllerTest.showGeneralSuccessAlert(localizedMessage, viewController: vc!, continueHandler: continueHandler)
                }
            }
        })
        
        if let handler = continueHandler {
            ac.addAction(UIAlertAction(title: actionContinueTitle, style: UIAlertActionStyle.Default) { action in handler() })
        }
        
        vc.presentViewController(ac, animated: true, completion: nil)
    }
}