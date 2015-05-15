//
//  FirstViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 03-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit



class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
//    let email : String = "boyd.rehorst+talent@icasting.com"
//    let password : String = "abc"

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "handleKeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "handleKeyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "handleKeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        if let access_token = Auth.auth.access_token {
            self.performSegueWithIdentifier("showCastingObjects", sender: self)
        }
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)

        
//        self.emailTextField.text = "tim.van.steenoven@icasting.com"
//        self.passwordTextField.text = "test"
        
        self.emailTextField.text = "boyd.rehorst+familie-account@icasting.com"
        self.passwordTextField.text = "abc"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Textfield Delegate Methods

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Notification Methods
    
    func handleKeyboardWillShow(notification: NSNotification) {

        println("keyboard will show")
        // Get the frame of the keyboard and place it in a CGRect
        let keyboardRectAsObject = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        var keyboardRect = CGRectZero
        keyboardRectAsObject.getValue(&keyboardRect)
        
        let offset = -keyboardRect.height / 2
        
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
    
    
    @IBAction func onButtonClickLogin(sender: UIButton) {
        
        // Create the credentials and check them against validation rules
        var c: Credentials = Credentials(email: emailTextField.text, password: passwordTextField.text)
        
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
            
            return
        }
        
        // Start the login proces
        SwiftSpinner.show("Login...")

        // The credentials are valid, try to login the user with the given credentials
        Auth().login(c) { errors in
            
            SwiftSpinner.hide()
            
            if let errors = errors {
                
                let fullStr: String = errors.localizedFailureReason
                
                let alertView = UIAlertView(
                    title: NSLocalizedString("Error", comment: ""),
                    message: fullStr,
                    delegate: nil,
                    cancelButtonTitle: nil,
                    otherButtonTitles: "Ok")
                
                alertView.show()
                
                return
            }
            
            // TEST LOGOUT
            //Auth().logout({ (failure) -> () in println(failure) })
            
            // Finally if there are no errors found, continue to main interface
            self.performSegueWithIdentifier("showCastingObjects", sender: self)
        }
        
    }
    
    @IBAction func prepareForUnwind(segue:UIStoryboardSegue) {
        
        
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    

    
    

}

