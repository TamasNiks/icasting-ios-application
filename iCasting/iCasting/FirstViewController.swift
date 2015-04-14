//
//  FirstViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 03-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    
    let email : String = "boyd.rehorst+talent@icasting.com"
    let password : String = "abc"
//    let email : String = "tim.van.steenoven@icasting.com"
//    let password : String = "test"
    
    @IBOutlet weak var testLabel: UILabel!
    
    @IBAction func onButtonClickLogin(sender: UIButton) {
        
        User.sharedInstance.login(email, password: password)
        
    }

    @IBAction func onButtonClickLogout(sender: UIButton) {
        
        User.sharedInstance.logout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    


}

