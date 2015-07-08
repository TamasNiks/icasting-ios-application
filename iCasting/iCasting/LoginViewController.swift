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
        // Do any additional setup after loading the view, typically from a nib.
        self.addObserver(self, forKeyPath: "tryToLogin", options: nil, context: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)

        // Create a keyboard controller with views to handle keyboard events
        self.keyboardController = KeyboardController(views: [self.emailTextField, self.passwordTextField])
        self.keyboardController?.setObserver()
        self.keyboardController?.goingUpDivider = 8
        
        // TODO: Comment this line on App Review
        setTestDataOnInputFields()
        
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
        
        // and check them against validation rules
        if !startValidateUserInput(c) {return}
        
        // The credentials are valid, try to login the user with the given credentials
        let appCredentials = Credentials()
        appCredentials.userCredentials = c
        startLoginSequence(appCredentials)
    }
    
    
    private func startValidateUserInput(c: UserCredentials) -> Bool {
        
        // Check for errors through the Validator class
        if let list = Validator(credentials: c).check() {
            
            var fullStr: String = ""
            for error: ErrorValidator in list {
                fullStr += String(format: "- %@",arguments: [error.getLocalizedDescription()])
                fullStr += "\n"
                println("Error: \(error.getLocalizedDescription())")
            }
            
            let alertView = UIAlertView(
                title: NSLocalizedString("Error", comment: ""),
                message: fullStr,
                delegate: nil,
                cancelButtonTitle: nil,
                otherButtonTitles: "Ok")
            
            alertView.show()
            
            return false
        }
        return true
    }
    
    
    private func tryLoginSequence() {
        
        println("LoginViewController: tryLoginSequence")
        
        // First check if the user still exists, whether through facebook or normal login
        if let
            access_token = Auth.auth.access_token,
            user_id = Auth.auth.user_id
        {
            startLoginSequence(Credentials())
        }
        // If the user doesn't have an authentication stored, check if Facebook is still logged in, if it is, logout, because the try to login depends totally on the access_token and user_id of iCasting. If it isn't there, the user should login manually, hence logout on facebook
        else {
            if let fbsdkCurrentAccessToken = FBSDKAccessToken.currentAccessToken() {
                FBSDKLoginManager().logOut()
            }
        }
    }
    
    
    private func startLoginSequence(c: Credentials) {
        
        self.tryToLogin = true

        // TODO: When the access_token expires, (if it will expire), we need to find a way with error messages from the server to clear the tokens
        
        Auth().login(c) { errors in
        
            self.tryToLogin = false
            
            if let errors = errors {
                
                println(errors)
                self.performErrorHandling(errors)
                return
            }
            
            // Check if the user is client, because clients are not yet supported, show an alert and log out
            
            if User.sharedInstance.isClient {
                
                let av = UIAlertView(title: NSLocalizedString("Announcement", comment: "Title of alert"),
                    message: NSLocalizedString("login.alert.client.notsupported", comment: ""),
                    delegate: nil,
                    cancelButtonTitle: nil,
                    otherButtonTitles: "Ok")
                av.show()
                
                Auth().logout({ (failure) -> () in println(failure) })
                return
            }
            
            // Try to register the device
            
            Push().registerDevice() { failure in
                
                if let failure = failure {
                    println("Registering failure")
                }
                
                if let config = Push.config {
                    println("DeviceID: \(config.deviceID)")
                    return
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
        
    }
    
    func performErrorHandling(errors: ICErrorInfo) {
        
        if errors is ICAPIErrorInfo {
            if (errors as! ICAPIErrorInfo).name == ICAPIErrorNames.PassportAuthenticationError.rawValue {
                println("Should do custom facebook logout")
                let login = FBSDKLoginManager()
                login.logOut()
            }
        }
        
        let fullStr: String = errors.localizedFailureReason
        let alertView = UIAlertView(
            title: NSLocalizedString("Login Error", comment: ""),
            message: fullStr,
            delegate: nil,
            cancelButtonTitle: nil,
            otherButtonTitles: "Ok")
        alertView.show()
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if tryToLogin == true {
            SwiftSpinner.show("Login...")
            self.loginButton.enabled = false
        } else {
            SwiftSpinner.hide()
            self.loginButton.enabled = true
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
    
    // Because the interface changes to another screen, the logout button wil never be seen. The user logs out via another screen. Thus we need to manage the logout manually.
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        Auth().logout({ (failure) -> () in println(failure) })
    }
}



// TEST: logout

extension LoginViewController {
    
    func setTestDataOnInputFields() {
        
        // Family account
        //        self.emailTextField.text = "tim.van.steenoven+family@icasting.com"
        //        self.passwordTextField.text = "test"
        
        //self.emailTextField.text = "tim.van.steenoven@icasting.com"
        //self.passwordTextField.text = "test"
        
        //self.emailTextField.text = "boyd.rehorst+familie-account@icasting.com"
        //self.passwordTextField.text = "abc"
        
        //        self.emailTextField.text = "timvs.nl@gmail.com"
        //        self.passwordTextField.text = "test"
        
        //self.emailTextField.text = "tobias+103@iqmedia.nl"
        //self.passwordTextField.text = "abc"
        
    }
    
    func testLogout() {
        Auth().logout({ (failure) -> () in println(failure) })
    }
    
}
