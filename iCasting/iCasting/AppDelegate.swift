//
//  AppDelegate.swift
//  iCasting
//
//  Created by T. van Steenoven on 03-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//
//190, 38, 52
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //var drawerController: DrawerController!
    

    // When the following scenario occurs:
    // - The user rejected push notificationa  
    // - It fails because there is no internet connection
    // - The Apple Push Notification (APN) server is down
    // - Code is running on a platform that doesn't support push notifications
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
     
        println("--- Reject remote notifications \(error)")
    }
    
    // - The device has been registered successfully with the app by the APN
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        println("--- Registerd successfully by the APN")
        
        var tokenAsString = NSMutableString()
        
        var byteBuffer = [UInt8](count: deviceToken.length, repeatedValue: 0x00)
        deviceToken.getBytes(&byteBuffer, length: byteBuffer.count)
        
        for byte in byteBuffer {
            tokenAsString.appendFormat("%02hhX", byte)
        }
        
        println("Token = \(tokenAsString)")
        
    }
    
    // When the following scenario occurs:
    // - The app is open and a push notification arrives
    // - The user didn't select an action
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        println("--- App did received remote notification while app was open")
    }
    
    // When the following scenario occurs:
    // - If the user selects an action if one is available
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
    
        println("--- User pressed an action")
    }

    func configureRemoteNotifications() {
        
        // Setup Action
        var notificationAction: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        notificationAction.title = "New match"
        notificationAction.identifier = "newMatchIdentifier"
        notificationAction.activationMode = UIUserNotificationActivationMode.Foreground
        notificationAction.destructive = false
        
        var notificationCategory: UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
        notificationCategory.identifier = "com.icasting.match"
        
        notificationCategory.setActions([notificationAction],
            forContext: UIUserNotificationActionContext.Minimal)
        
        
        // Put it in a set
        let notificationCategories = NSSet(object: notificationCategory)
        
        let notificationSettingsWithAction = UIUserNotificationSettings(
            forTypes: UIUserNotificationType.Alert,
            categories: notificationCategories as Set<NSObject>)
        
        // Users can change their notification settings at any time using the Settings app. Your app is added to the Settings app as soon as you call registerUserNotificationSettings:. Users can enable or disable notifications, as well as modify where and how notifications are presented. Because the user can change their initial setting at any time, call currentUserNotificationSettings before you do any work preparing a notification for presentation.
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettingsWithAction)
        
        // If called for the first time, the system will pop up a dialog box asking if the user wants to grant permission to display notifications
        UIApplication.sharedApplication().registerForRemoteNotifications()

    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // When the following scenario occurs:
        // - A notification is delivered while the app was not open 
        // - The user entered the app via the notification
        //let key: NSString = NSString(string: UIApplicationLaunchOptionsRemoteNotificationKey())
        
        if let launchOptions = launchOptions {
         
            let dict: NSDictionary = NSDictionary(dictionary: launchOptions)
            if let remoteNotification: AnyObject? = dict.objectForKey(UIApplicationLaunchOptionsRemoteNotificationKey) {
                
               println(remoteNotification)
                
            }

        }
        
        // SETUP NOTIFICATION
        configureRemoteNotifications()

        
        
        // Configuration of the drawer controller
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let initialViewController = storyBoard.instantiateViewControllerWithIdentifier("login") as? UIViewController
        //let initialViewController = storyBoard.instantiateViewControllerWithIdentifier("dashboard") as? UIViewController
        //(initialViewController as? UITabBarController)?.selectedIndex = 3
        //let leftSideDrawerViewController = ExampleLeftSideDrawerViewController()
        
        //let leftSideNavController = UINavigationController(rootViewController: leftSideDrawerViewController)
        //leftSideNavController.restorationIdentifier = "ExampleLeftNavigationControllerRestorationKey"
        //self.drawerController = DrawerController(centerViewController: centerViewController, leftDrawerViewController: leftSideDrawerViewController)
        //self.setupDrawerController()
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        
        // Change the global appearence190, 38, 52
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        //UINavigationBar.appearance().barTintColor = UIColor(red: 213/255, green: 0, blue: 42/255, alpha: 1) //D5002A
        //UINavigationBar.appearance().barTintColor = UIColor(red: 221/255, green: 33/255, blue: 49/255, alpha: 1) //D5002A //sRGB
        //UINavigationBar.appearance().barTintColor = UIColor(red: 190/255, green: 38/255, blue: 52/255, alpha: 1) //D5002A //Adobe RGB
        UINavigationBar.appearance().barTintColor = UIColor.ICRedDefaultColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        /*
        // iOS 7:
        UITableView.appearance().separatorStyle = .SingleLine
        UITableView.appearance().separatorInset = UIEdgeInsetsZero
        UITableViewCell.appearance().separatorInset = UIEdgeInsetsZero
        
        // iOS 8:
        if UITableView.instancesRespondToSelector("setLayoutMargins:") {
            UITableView.appearance().layoutMargins = UIEdgeInsetsZero
            UITableViewCell.appearance().layoutMargins = UIEdgeInsetsZero
            UITableViewCell.appearance().preservesSuperviewLayoutMargins = false
        }
        */
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /*func setupDrawerController() {
    drawerController.drawerVisualStateBlock = { (drawerController, drawerSide, percentVisible) in
    let block = ExampleDrawerVisualStateManager.sharedManager.drawerVisualStateBlockForDrawerSide(drawerSide)
    block?(drawerController, drawerSide, percentVisible)
    }
    drawerController.showsShadows = false
    drawerController.restorationIdentifier = "Drawer"
    drawerController.maximumRightDrawerWidth = 200.0
    drawerController.openDrawerGestureModeMask = .All
    drawerController.closeDrawerGestureModeMask = .All
    }*/


}

