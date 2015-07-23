//
//  FirstViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 03-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func prepareForUnwind(segue:UIStoryboardSegue) {}
    
    dynamic var tryToLogin: Bool = false
    
    var keyboardController: KeyboardController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObserver(self, forKeyPath: "tryToLogin", options: nil, context: nil)
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
        tryLoginSequence()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.keyboardController?.removeObserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    // Normal login
    
    @IBAction func onButtonClickLogin(sender: UIButton) {
        
        // Create the credentials
        var c: UserCredentials = UserCredentials(email: emailTextField.text, password: passwordTextField.text)
        
        // and check them against validation rules, stop executing the functions if there are errors
        if !validateUserInput(c) { return }
        
        // The credentials are valid, try to login the user with the given credentials
        let appCredentials = Credentials()
        appCredentials.userCredentials = c
        startLoginSequence(appCredentials)
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
    
    
    private func tryLoginSequence() {
        
        println("LoginViewController: tryLoginSequence")
        
        // First check if the user still exists, whether through facebook or normal login
        if let passport = Auth.passport
        {
            // Because the user is still loged in, we give don't send credentials as parameters
            startLoginSequence(nil)
        }
        // If the user doesn't have an passport authentication stored, check if Facebook is still logged in, if it is, logout, because the try to login depends totally on the access_token and user_id of iCasting. If it isn't there, the user should login manually, hence logout on facebook
        else {
            if let fbsdkCurrentAccessToken = FBSDKAccessToken.currentAccessToken() {
                FBSDKLoginManager().logOut()
            }
        }
    }
    
    
    private func startLoginSequence(c: Credentials?) {
        
        self.tryToLogin = true

        Auth.login(c) { error in

            // First do some error handling from the login
            if let error = error {
                self.performErrorHandling(error)
                return
            }
            
            // Create a completionHandler which gets called after all the necessary requests are done
            let completionHandler: () -> () = {

                self.tryToLogin = false
                
                // Check if the user is client, because clients are not yet supported, show an alert and log out
                
                if User.sharedInstance.isClient {
                    
                    let title = NSLocalizedString("Announcement", comment: "Title of alert")
                    let message = NSLocalizedString("login.alert.client.notsupported", comment: "")
                    let av = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Ok")
                    av.show()
                    
                    Auth.logout({ (failure) -> () in println(failure) })
                    return
                }
                
                // Try to register the device
                
                Push().registerDevice() { error in
                    
                    if let error = error {
                        println("DEBUG: Registering failure - \(error)")
                    }
                }
                
                // If the user is not a client or talent, it is a manager, it will have casting objects, show the overview
                
                if User.sharedInstance.isManager {
                    
                    self.performSegueWithIdentifier("showCastingObjects", sender: self)
                    return
                }
                
                // If the user is talent, there's just one casting object, it has already been set in the model
                
                self.performSegueWithIdentifier("showMain", sender: self)
            }
            
            
            // Do the following up HTTP requests to get the app data
            
            // Get general user information
            UserRequest().execute { error -> () in
                
                if let error = error {
                    self.performErrorHandling(error)
                    return
                }
                
                // Get the casting object(s) from the user account
                CastingObjectRequest().execute { error -> () in
                    
                    if let error = error {
                        self.performErrorHandling(error)
                        return
                    }
                    
                    println(User.sharedInstance)
                    completionHandler()
                }
            }
            
        }
        
    }
    
    func performErrorHandling(errors: ICErrorInfo) {
        
        self.tryToLogin = false
        
        println(errors)
        
        if errors is ICAPIErrorInfo {
            if (errors as! ICAPIErrorInfo).name == ICAPIErrorNames.PassportAuthenticationError.rawValue {
                println("Should do custom facebook logout")
                let login = FBSDKLoginManager()
                login.logOut()
            }
        }
        
        let message = errors.localizedFailureReason
        let title = NSLocalizedString("Login Error", comment: "")
        let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Ok")
        alertView.show()
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "tryToLogin" {
            if tryToLogin == true {
                SwiftSpinner.show("Login...")
                self.loginButton.enabled = false
            } else {
                SwiftSpinner.hide()
                self.loginButton.enabled = true
            }
        }
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
            startLoginSequence(credentials)
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
