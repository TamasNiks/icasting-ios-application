//
//  MainViewController.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    
    let kMatchesOverview: Int = 1
    let kNegotiationsOverview: Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "setIndex:",
            name: kReceivedRemoteNotificationKey,
            object: nil)
        
        // Do any additional setup after loading the view.
        self.selectedIndex = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setIndex(sender: NSNotification) {
        
        if let userInfo = sender.userInfo {
            
            if let userInfoTemplate = userInfo["template"] as? String {

                if let template = RemoteNotificationTemplate(rawValue: userInfoTemplate) {
                    
                    switch template {
                        
                    case .TalentMatched:
                        // Show the talent
                        self.selectedIndex = kMatchesOverview
                        println(template.rawValue)
                    case .MatchClientAccepted:
                        self.selectedIndex = kMatchesOverview
                        println(template.rawValue)
                    case .FirstConversationMessage:
                        self.selectedIndex = kNegotiationsOverview
                        println(template.rawValue)
                    case .TalentCreditslip:
                        println(template.rawValue)
                    case .TalentJobReminder:
                        println(template.rawValue)
                    case .TalentRated:
                        println(template.rawValue)
                    }
                }
                
                println("WILL SET INDEX")
            }
        }
    }
}
