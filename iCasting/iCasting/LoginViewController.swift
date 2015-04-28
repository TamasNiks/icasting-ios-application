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

    var error : Error?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func onButtonClickLogin(sender: UIButton) {
        
        // Create the credentials and check them against validation rules
        var c: Credentials = Credentials(email: emailTextField.text, password: passwordTextField.text)

        // Check for errors through the Validator class
        if let list = Validator(credentials: c).check() {
            for error: ErrorValidator in list {
                println("Error: \(error.getDescription())")
            }
            return
        }
        
        // The credentials are valid, try to login the user
        User.sharedInstance.login(c) { result in
            self.performSegueWithIdentifier("showMain", sender: self)
        }
        
    }

    @IBAction func onButtonClickLogout(sender: UIButton) {
        
        //User.sharedInstance.logout()
    }
    
    
    func onKeyboardWillShow(notification: NSNotification ) {
        
        println("KeyBoard Will Show")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var nc : NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "onKeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }

    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    

}

