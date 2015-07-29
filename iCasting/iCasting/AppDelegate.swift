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
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate {
    
    var window: UIWindow?
    
    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"
    let subscriptionTopic = "/topics/global"
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        println("application:didFinishLaunchingWithOptions")
        
        // Configure the Google context: parses the GoogleService-Info.plist, and initializes
        // the services that have entries in the file
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        if configureError != nil {
            println("Error configuring the Google context: \(configureError)")
        }
        
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        
        configureAndRegisterRemoteNotifications(application)

        GCMService.sharedInstance().startWithConfig(GCMConfig.defaultConfig())

        
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyBoard.instantiateViewControllerWithIdentifier("login") as? UIViewController
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        UINavigationBar.appearance().barTintColor = UIColor.ICRedDefaultColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        if(registrationToken != nil && connectedToGCM) {
            GCMPubSub.sharedInstance().subscribeWithToken(self.registrationToken, topic: subscriptionTopic,
                options: nil, handler: {(NSError error) -> Void in
                    if (error != nil) {
                        // Treat the "already subscribed" error more gently
                        if error.code == 3001 {
                            println("Already subscribed to \(self.subscriptionTopic)")
                        } else {
                            println("Subscription failed: \(error.localizedDescription)");
                        }
                    } else {
                        self.subscribedToTopic = true;
                        NSLog("Subscribed to \(self.subscriptionTopic)");
                    }
            })
        }
    }
    

    func applicationDidBecomeActive( application: UIApplication) {
        // Connect to the GCM server to receive non-APNS notifications
        
        GCMService.sharedInstance().connectWithHandler({
            (NSError error) -> Void in
            if error != nil {
                println("Could not connect to GCM: \(error.localizedDescription)")
            } else {
                self.connectedToGCM = true
                println("Connected to GCM")
                self.subscribeToTopic()
            }
        })
    }

    
    func applicationDidEnterBackground(application: UIApplication) {
        
        GCMService.sharedInstance().disconnect()
        self.connectedToGCM = false
    }

    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {

        // Start the GGLInstanceID shared instance with the default config and request a registration
        // token to enable reception of notifications
        GGLInstanceID.sharedInstance().startWithConfig(GGLInstanceIDConfig.defaultConfig())
        
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken, kGGLInstanceIDAPNSServerTypeSandboxOption:true]
    
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM,
            options: registrationOptions,
            handler: registrationHandler)
    }
    

    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
        
            println("Registration for remote notification failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(registrationKey, object: nil, userInfo: userInfo)
    }
    

    func application( application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        println("Notification received: \(userInfo)")
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
        // Handle the received message

        
        
        
        //NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil, userInfo: userInfo)
    }
    
    
    func application( application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
        
        println("Notification received fetch completion handler: \(userInfo)")
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo)
        
        // Handle the received message
        // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
        
        
        if application.applicationState == UIApplicationState.Active {

            let notification = CWStatusBarNotification()
            notification.notificationLabelBackgroundColor = UIColor.redColor()
            notification.notificationStyle = CWNotificationStyle.NavigationBarNotification
            notification.displayNotificationWithMessage("Hello World", forDuration: 4.0)
            
            let receivedNotificationKey = "PushNotification"
            NSNotificationCenter.defaultCenter().postNotificationName(receivedNotificationKey, object: nil, userInfo: userInfo)
            //NSNotificationCenter.defaultCenter().postNotification(notification: NSNotification)

        } else {

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let localNotification = UILocalNotification()
                localNotification.alertTitle = "The title of the notification"
                localNotification.alertBody = "The body of the notification"
                localNotification.userInfo = nil
                localNotification.fireDate = NSDate()
                //application.presentLocalNotificationNow(localNotification)
                application.scheduleLocalNotification(localNotification)
                
            })
            
        }
    
        handler(UIBackgroundFetchResult.NoData)
    }

    
    func registrationHandler(registrationToken: String!, error: NSError!) {

        if (registrationToken != nil) {
            self.registrationToken = registrationToken
            println("Registration Token: \(registrationToken)")
            self.subscribeToTopic()
            
            saveGCMRegistrationToken(registrationToken)
            
            let userInfo = ["registrationToken": registrationToken]
            NSNotificationCenter.defaultCenter().postNotificationName(self.registrationKey, object: nil, userInfo: userInfo)
        } else {
            println("Registration to GCM failed with error: \(error.localizedDescription)")
            
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(self.registrationKey, object: nil, userInfo: userInfo)
        }
    }
    

    func onTokenRefresh() {
        
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        println("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM,
            options: registrationOptions,
            handler: registrationHandler)
    }

}


func configureAndRegisterRemoteNotifications(application: UIApplication) {

    // Register for remote notifications
    var types: UIUserNotificationType = UIUserNotificationType.Badge |
        UIUserNotificationType.Alert |
        UIUserNotificationType.Sound
    
    var settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
    
    application.registerUserNotificationSettings(settings)
    
    application.registerForRemoteNotifications()
}


func saveAPNSDeviceToken(token: NSData) {
    
    PushToken.token = PushNotificationDevice.convertDeviceTokenToHexadecimal(token)
}


func saveGCMRegistrationToken(token: String) {
    // TODO: It is not 100% guaranteed that a registration token will be set if a user logs in and want to register the device, come up with something that handles this.
    println("AppDelegate: GCM token will be saved")
    PushToken.token = token
}



/*
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate {

    var window: UIWindow?

    //var drawerController: DrawerController!
    

    /* GCM */
    var gcmSenderID: String?
    var registrationOptions = [String: AnyObject]()
    var registrationToken: String?
    var connectedToGCM = false
    let subscriptionTopic = "/topics/global"
    var subscribedToTopic = false
    //let registrationKey = "onRegistrationCompleted"
    
    // When the following scenario occurs:
    // - The user rejected push notificationa  
    // - It fails because there is no internet connection
    // - The Apple Push Notification (APN) server is down
    // - Code is running on a platform that doesn't support push notifications
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
     
        println("--- Reject remote notifications \(error)")
        println("Registration for remote notification failed with error: \(error.localizedDescription)")
    }
    
    // - The device has been registered successfully with the app by the APN
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        println("--- Registerd successfully by the APN")

        //let deviceTokenAsString = convertDeviceTokenToHexadecimal(deviceToken)
        
        // GCM
        // Start the GGLInstanceID shared instance with the default config and request a registration
        // token to enable reception of notifications
        GGLInstanceID.sharedInstance().startWithConfig(GGLInstanceIDConfig.defaultConfig())

        registrationOptions = [
            kGGLInstanceIDRegisterAPNSOption:deviceToken,
            kGGLInstanceIDAPNSServerTypeSandboxOption:true
        ]
        
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM,
            options: registrationOptions,
            handler: registrationHandler)
    }
    
    // GCM: After registering with the GCM, you get a registration token
    func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            println("Registration Token: \(registrationToken)")
            self.registrationToken = registrationToken
            self.subscribeToTopic()
            //self.saveGCMRegistrationToken(registrationToken)
        } else {
            println("Registration to GCM failed with error: \(error.localizedDescription)")
        }
    }
    
    
    func onTokenRefresh() {
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM,
            options: registrationOptions,
            handler: registrationHandler)
    }
    
    
    private func saveAPNSDeviceToken(token: NSData) {
        
        PushToken.token = Push.convertDeviceTokenToHexadecimal(token)
    }
    
    private func saveGCMRegistrationToken(token: String) {
        // TODO: It is not 100% guaranteed that a registration token will be set if a user logs in and want to register the device, come up with something that handles this.
        PushToken.token = token
    }
    

    
    // When the following scenario occurs:
    // - The app is active and a push notification arrives
    // - The user didn't select an action
    // - GCM: This delegate gets called when the message contains collapse_key
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        
//        println("--- App did received remote notification while app was active")
//        println("Notification received: \(userInfo)")
//        // This works only if the app started the GCM service
//        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
//        
//    }
    
    // [START ack_message_reception]
    func application( application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
            println("Notification received: \(userInfo)")
            // This works only if the app started the GCM service
            GCMService.sharedInstance().appDidReceiveMessage(userInfo);
            // Handle the received message
    }
    
    
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        println("Notification received fetch completion handler: \(userInfo)")
        
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo)
        
        // Handle the received message
        // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
        // ...
        completionHandler(UIBackgroundFetchResult.NoData)
    }
    
    
    
    // When the following scenario occurs:
    // - If the user selects an action if one is available
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
    
        println("--- User pressed an action")
    }

    func configureRemoteNotifications() {
        
        // Configure the Google context: parses the GoogleService-Info.plist, and initializes
        // the services that have entries in the file
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        if configureError != nil {
            println("Error configuring the Google context: \(configureError)")
        }
        
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        println("GCMSENDERID")
        println(gcmSenderID)
        
        /*
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
        */

        
        var types: UIUserNotificationType = UIUserNotificationType.Badge |
            UIUserNotificationType.Alert |
            UIUserNotificationType.Sound
        var settings: UIUserNotificationSettings =
        UIUserNotificationSettings( forTypes: types, categories: nil )
        

        // Users can change their notification settings at any time using the Settings app. Your app is added to the Settings app as soon as you call registerUserNotificationSettings:. Users can enable or disable notifications, as well as modify where and how notifications are presented. Because the user can change their initial setting at any time, call currentUserNotificationSettings before you do any work preparing a notification for presentation.
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        // If called for the first time, the system will pop up a dialog box asking if the user wants to grant permission to display notifications
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    
    
    
    // MARK: - Application delegates
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // When the following scenario occurs:
        // - A notification is delivered while the app was not open
        // - The user entered the app via the notification
        //let key: NSString = NSString(string: UIApplicationLaunchOptionsRemoteNotificationKey)
        
//        if let launchOptions = launchOptions {
//         
//            let dict: NSDictionary = NSDictionary(dictionary: launchOptions)
//            if let remoteNotification: AnyObject? = dict.objectForKey(UIApplicationLaunchOptionsRemoteNotificationKey) {
//               println(remoteNotification)
//            }
//        }
        
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyBoard.instantiateViewControllerWithIdentifier("login") as? UIViewController
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        // iOS 8.3
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
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
        
        // SETUP NOTIFICATION
        configureRemoteNotifications()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        GCMService.sharedInstance().disconnect()
        self.connectedToGCM = false
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

//    func applicationDidBecomeActive(application: UIApplication) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        println("applicationDidBecomeActive")
//        // GCM
//        GCMService.sharedInstance().connectWithHandler { (error: NSError!) -> Void in
//            if let error = error {
//                println("Could not connect to GCM: \(error.localizedDescription)")
//            } else {
//                self.connectedToGCM = true
//                println("Connected to GCM")
//            }
//            
//            
//        }
//        
//        // FACEBOOK
//        FBSDKAppEvents.activateApp()
//    }

    
    // [START connect_gcm_service]
    func applicationDidBecomeActive( application: UIApplication) {
        // Connect to the GCM server to receive non-APNS notifications
        
//        let main_queue = dispatch_get_main_queue()
//        dispatch_async(main_queue, { () -> Void in

            GCMService.sharedInstance().connectWithHandler({
                (NSError error) -> Void in
                if error != nil {
                    println("Could not connect to GCM: \(error.localizedDescription)")
                } else {
                    self.connectedToGCM = true
                    println("Connected to GCM")
                    // [START_EXCLUDE]
                    self.subscribeToTopic()
                    // [END_EXCLUDE]
                }
            })
            
//        })
        
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

    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        if(registrationToken != nil && connectedToGCM) {
            GCMPubSub.sharedInstance().subscribeWithToken(self.registrationToken, topic: subscriptionTopic,
                options: nil, handler: {(NSError error) -> Void in
                    if (error != nil) {
                        // Treat the "already subscribed" error more gently
                        if error.code == 3001 {
                            println("Already subscribed to \(self.subscriptionTopic)")
                        } else {
                            println("Subscription failed: \(error.localizedDescription)");
                        }
                    } else {
                        self.subscribedToTopic = true;
                        NSLog("Subscribed to \(self.subscriptionTopic)");
                    }
            })
        }
    }
    
    

}
*/
