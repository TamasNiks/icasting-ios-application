//
//  FirstViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 03-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit



class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    dynamic var tryToLogin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "handleKeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "handleKeyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "handleKeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.addObserver(self, forKeyPath: "tryToLogin", options: nil, context: nil)
        
        tryLoginSequence()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)

        
        self.emailTextField.text = "tim.van.steenoven@icasting.com"
        self.passwordTextField.text = "test"
        
//        self.emailTextField.text = "boyd.rehorst+familie-account@icasting.com"
//        self.passwordTextField.text = "abc"
        
//        self.emailTextField.text = "timvs.nl@gmail.com"
//        self.passwordTextField.text = "test"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func prepareForUnwind(segue:UIStoryboardSegue) {}
    
    // MARK: Textfield Delegate Methods

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    
    
    @IBAction func onButtonClickLogin(sender: UIButton) {
        
        // Create the credentials
        var c: Credentials = Credentials(email: emailTextField.text, password: passwordTextField.text)
        
        // and check them against validation rules
        if !startValidateUserInput(c) {return}
        
        // The credentials are valid, try to login the user with the given credentials
        startLoginSequence(c)
        
    }
    
    
    private func startValidateUserInput(c: Credentials) -> Bool {
        
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
        if let
            access_token = Auth.auth.access_token,
            user_id = Auth.auth.user_id
        {
            startLoginSequence(Credentials())
        }
    }
    
    
    private func startLoginSequence(c: Credentials) {
        
        self.tryToLogin = true

        // TODO: When the access_token expires, (if it will expire, we need to find a way through error messages to clear the tokens)
        Auth().login(c) { errors in
        
            self.tryToLogin = false
            
            
            if let errors = errors {
                
                let fullStr: String = errors.localizedFailureReason
                
                let alertView = UIAlertView(
                    title: NSLocalizedString("Login Error", comment: ""),
                    message: fullStr,
                    delegate: nil,
                    cancelButtonTitle: nil,
                    otherButtonTitles: "Ok")
                
                alertView.show()
                
                return
            }
            
            
            // Check if the user is client
            
            if User.sharedInstance.general!.roles[0] == "client" {
                let av = UIAlertView(title: NSLocalizedString("Announcement", comment: "Title of alert"),
                    message: NSLocalizedString("login.alert.client.notsupported", comment: ""),
                    delegate: nil,
                    cancelButtonTitle: nil,
                    otherButtonTitles: "Ok")
                av.show()
                
                Auth().logout({ (failure) -> () in println(failure) })
                
                return
            }
            
            
            // TEST LOGOUT
            //Auth().logout({ (failure) -> () in println(failure) })
            
            // Finally if there are no errors found, continue to main interface
            self.performSegueWithIdentifier("showCastingObjects", sender: self)
        }
        
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


extension LoginViewController {
    
    
    // MARK: Notification Methods
    
    func handleKeyboardWillShow(notification: NSNotification) {
        
        println("keyboard will show")
        // Get the frame of the keyboard and place it in a CGRect
        let keyboardRectAsObject = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        var keyboardRect = CGRectZero
        keyboardRectAsObject.getValue(&keyboardRect)
        
        let offset = -keyboardRect.height / 3
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            
            self.emailTextField.transform = CGAffineTransformMakeTranslation(0, offset)
            self.passwordTextField.transform = CGAffineTransformMakeTranslation(0, offset)
            
        })
    }
    
    
    func handleKeyboardWillHide(notification: NSNotification) {
        
        println("keyboard will hide")
        // Get the frame of the keyboard and place it in a CGRect
        let keyboardRectAsObject = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        var keyboardRect = CGRectZero
        keyboardRectAsObject.getValue(&keyboardRect)
        
        let offset = CGFloat(0)//keyboardRect.height / 2
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            
            self.emailTextField.transform = CGAffineTransformMakeTranslation(0, offset)
            self.passwordTextField.transform = CGAffineTransformMakeTranslation(0, offset)
            
        })
        
    }
    
    func handleKeyboardDidShow(notification: NSNotification) {
        println("keyboard did show")
    }
    
    
}
