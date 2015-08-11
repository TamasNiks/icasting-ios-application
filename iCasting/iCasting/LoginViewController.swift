//
//  FirstViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 03-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit
//import FBSDKCoreKit
import FBSDKLoginKit


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func prepareForUnwind(segue:UIStoryboardSegue) {}
    
    //dynamic var tryToLogin: Bool = false
    let loginSequenceController = LoginSequenceController()
    let kTryToLoginKeyPath = "loginSequenceController.tryToLogin"
    var keyboardController: KeyboardController?
    
    
    
    // MARK: ViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObserver(self, forKeyPath: kTryToLoginKeyPath, options: nil, context: nil)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)

        // Create a keyboard controller with views to handle keyboard events
        self.keyboardController = KeyboardController(views: [self.emailTextField, self.passwordTextField])
        self.keyboardController?.setObserver()
        self.keyboardController?.goingUpDivider = 8
        
        // TODO: Comment this line when going through App Review
        setTestDataOnInputFields()
        
        // Try to login, if there's authentication data stored somewhere, it will login
        loginSequenceController.tryLoginSequence((success: {
        
                self.performRightSegue()
            
            }, failure: { error in
        
                self.performErrorHandling(error)
        }))
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.keyboardController?.removeObserver()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // Normal login
    
    @IBAction func onButtonClickLogin(sender: UIButton) {
        
        // Create the credentials
        var c: UserCredentials = UserCredentials(email: emailTextField.text, password: passwordTextField.text)
        
        // and check them against validation rules, stop executing the functions if there are errors
        if !validateUserInput(c) { return }
        
        // The credentials are valid, try to login the user with the given credentials
        let credentials = Credentials()
        credentials.userCredentials = c
        
        loginSequenceController.startLoginSequence(credentials, result: (success: {
            
                self.performRightSegue()
            
            }, failure: { error in
        
                self.performErrorHandling(error)
            }
        ))
    }
    
    
    private func validateUserInput(c: UserCredentials) -> Bool {
        
        // Check for errors through the Validator class
        if let list = Validator(credentials: c).check() {
            
            var message: String = ""
            for error: ErrorValidator in list {
                message += String(format: "- %@",arguments: [error.getLocalizedDescription()])
                message += "\n"
                println("Error: \(error.getLocalizedDescription())")
            }
            
            let title = NSLocalizedString("Error", comment: "")
            let alertView = UIAlertView( title: title, message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Ok")
            alertView.show()
            
            return false
        }
        return true
    }
    
     
    private func performRightSegue() {
     
        // If the user is not a client or talent, it is a manager, it will have casting objects, show the overview
        
        if User.sharedInstance.isManager {
            
            self.performSegueWithIdentifier(SegueIdentifier.CastingObjects, sender: self)
            return
        }
        
        // If the user is talent, there's just one casting object, it has already been set in the model
        self.performSegueWithIdentifier(SegueIdentifier.Main, sender: self)
    }
    
    
    private func performErrorHandling(errorInfo: ICErrorInfo) {
        
        loginSequenceController.tryToLogin = false
        
        println(errorInfo)

        if let errorInfo = errorInfo as? ICAPIErrorInfo {
            if errorInfo.name == ICAPIErrorNames.PassportAuthenticationError.rawValue {
                println("Should do custom facebook logout")
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
            }
        }
        
        if errorInfo.error.code == kICErrorEmailNotVerified {
        
            ICAlertControllerTest.showEmailVerificationAlert(errorInfo, viewController: self, continueHandler: { [weak self] () in
                    self?.performRightSegue()
                }, cancelHandler: { () in
                    Auth.logout() { failure in }
                }
            )
        }
        else {
            
            ICAlertControllerTest.showGeneralErrorAlert(errorInfo, viewController: self)
            
        }
    }
    

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if keyPath == kTryToLoginKeyPath {
            
            if loginSequenceController.tryToLogin == true {
                SwiftSpinner.show("Login...")
                self.loginButton.enabled = false
            }
            else {
                SwiftSpinner.hide()
                self.loginButton.enabled = true
            }
        }
    }
    
    
    
    // MARK: Textfield Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField != self.passwordTextField {
            self.passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}




// Adds support for Facebook login

extension LoginViewController : FBSDKLoginButtonDelegate {
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if let error = error {
        }
        else if result.isCancelled {
        }
        else {
            
            let credentials = Credentials()
            credentials.facebookCredentials = FacebookCredentials(userID: result.token.userID)

            loginSequenceController.startLoginSequence(credentials, result: (success: {
                
                    self.performRightSegue()
                
                }, failure: { error in
                    
                    self.performErrorHandling(error)
                    
                }
            ))
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // Because the interface changes to another screen, the logout button wil never be seen. The user logs out via another screen. Thus we need to manage the logout manually.
        Auth.logout { error in println(error) }
    }
}



// TEST: logout

extension LoginViewController {
    
    func setTestDataOnInputFields() {
        
        // Family account
        //self.emailTextField.text = "tim.van.steenoven+family@icasting.com"
        //self.passwordTextField.text = "test"
        
        self.emailTextField.text = "tim.van.steenoven@icasting.com"
        self.passwordTextField.text = "test"
        
//        self.emailTextField.text = "boyd.rehorst+familie-account@icasting.com"
//        self.passwordTextField.text = "abc"
        
        //        self.emailTextField.text = "timvs.nl@gmail.com"
        //        self.passwordTextField.text = "test"
        
        //self.emailTextField.text = "tobias+103@iqmedia.nl"
        //self.passwordTextField.text = "abc"
        
    }
    
    func testLogout() {
        Auth.logout { error in println(error) }
    }
    
}
