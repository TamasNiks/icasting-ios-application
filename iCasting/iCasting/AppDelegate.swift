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


//        let blurredBackgroundView = BlurredBackgroundView(frame: CGRectZero)
//        tableView.backgroundView = blurredBackgroundView
//        tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurredBackgroundView.blurView.effect as! UIBlurEffect)


public let kReceivedRemoteNotificationKey: String = "ReceivedRemoteNotificationKey"

enum RemoteNotificationTemplate: String {
    
    case TalentMatched = "talent-matched"
    case MatchClientAccepted = "match-client-accepted"
    case TalentJobReminder = "talent-job-reminder"
    case TalentRated = "talent-rated"
    case TalentCreditslip = "talent-creditslip"
    case FirstConversationMessage = "first-conversation-message"
}


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
        
        //testNotification()
        
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
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
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
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        GCMService.sharedInstance().disconnect()
        self.connectedToGCM = false
    }

    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
    
        // When the following scenario occurs:
        // - The user rejected push notificationa
        // - It fails because there is no internet connection
        // - The Apple Push Notification (APN) server is down
        // - Code is running on a platform that doesn't support push notifications
        
        println("Registration for remote notification failed with error: \(error.localizedDescription)")
        let userInfo = ["error": error.localizedDescription]
        NSNotificationCenter.defaultCenter().postNotificationName(registrationKey, object: nil, userInfo: userInfo)
    }
    
    
    func configureAndRegisterRemoteNotifications(application: UIApplication) {
        
        // Register for remote notifications
        var types: UIUserNotificationType = UIUserNotificationType.Badge |
            UIUserNotificationType.Alert |
            UIUserNotificationType.Sound
        
        var settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
        
        
        // Users can change their notification settings at any time using the Settings app. Your app is added to the Settings app as soon as you call registerUserNotificationSettings:. Users can enable or disable notifications, as well as modify where and how notifications are presented. Because the user can change their initial setting at any time, call currentUserNotificationSettings before you do any work preparing a notification for presentation.
        application.registerUserNotificationSettings(settings)
        
        application.registerForRemoteNotifications()
    }
    
    
    // When the following scenario occurs:
    // - The app is active and a push notification arrives
    // - The user didn't select an action
    // - GCM: This delegate gets called when the message contains collapse_key
    func application( application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        println("Notification received: \(userInfo)")
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
        // Handle the received message
        //NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil, userInfo: userInfo)
    }
    
    
    // Handle the notifications
    func application( application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
        
        println("AppDelegate: Notification received fetch completion handler: \(userInfo)")

        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo)
        
        // Handle the received message
        // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
        // Show the right kind of notification depending on the application state
        if application.applicationState == UIApplicationState.Active {

            showForegroundNotification(application, userInfo: userInfo)

        } else {

            showBackgroundNotification(application, userInfo: userInfo)
        }
    
        handler(UIBackgroundFetchResult.NoData)
    }

    
    // After the user taps on a local notification, which has been created after fetching an invicible remote notification, 
    // post a notification to the observer whom handle the userInfo
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        println("AppDelegate: Did receive a local notification")
        NSNotificationCenter.defaultCenter().postNotificationName(kReceivedRemoteNotificationKey, object: nil, userInfo: notification.userInfo)
    }
    
    // When the following scenario occurs:
    // - If the user selects an action if one is available
//    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
//        
//        println("--- User pressed an action")
//    }
    
//    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
//        println("--- User pressed an action from a local notification")
//    }
    
    func showBackgroundNotification(application: UIApplication, userInfo: [NSObject : AnyObject]) {
        
//        let title = userInfo["title"] as? String
//        let message = userInfo["message"] as? String
        if let (title, message, template) = extractUserInfoForNotification(userInfo) {
            
            let localNotification = UILocalNotification()
            localNotification.alertTitle = title
            localNotification.alertBody = message
            localNotification.userInfo = userInfo
            application.presentLocalNotificationNow(localNotification)
            
        }
    }
    
    
    func showForegroundNotification(application: UIApplication, userInfo: [NSObject : AnyObject]) {

//        var title = userInfo["title"] as? String
//        var message = userInfo["message"] as? String
//        let template = userInfo["template"] as? String
//        
//        if template == nil { return }
//        
//        if let template = RemoteNotificationTemplate(rawValue: template!) {
//            
//            title = NSLocalizedString(String(format: "remote.notification.%@.title", template.rawValue), comment: "")
//            message = NSLocalizedString(String(format: "remote.notification.%@.message", template.rawValue), comment: "")
//        }

        if let (title, message, template) = extractUserInfoForNotification(userInfo) {
            
            let notificationView: NotificationView = NSBundle.mainBundle().loadNibNamed(
                "NotificationView", owner: self, options: nil)[0] as! NotificationView
            notificationView.title.text = title
            notificationView.message.text = message
            
            let notification = CWStatusBarNotification()
            notification.notificationLabelBackgroundColor = UIColor.darkGrayColor()
            notification.notificationStyle = CWNotificationStyle.NavigationBarNotification
            notification.displayNotificationWithView(notificationView, forDuration: 10.0)
            
            notification.notificationTappedBlock = {
                
                notification.dismissNotification()
                NSNotificationCenter.defaultCenter().postNotificationName(kReceivedRemoteNotificationKey, object: nil, userInfo: userInfo)
            }
        }
    }
    
    
    func extractUserInfoForNotification(userInfo: [NSObject : AnyObject]) -> (title: String?, message: String?, template: String)? {
     
        var title = userInfo["title"] as? String
        var message = userInfo["message"] as? String
        let template = userInfo["template"] as? String
        
        if template == nil { return nil }
        
        if let template = RemoteNotificationTemplate(rawValue: template!) {
            
            title = NSLocalizedString(String(format: "remote.notification.%@.title", template.rawValue), comment: "")
            message = NSLocalizedString(String(format: "remote.notification.%@.message", template.rawValue), comment: "")
        }
        
        return (title: title, message: message, template: template!)
    }
    
    
    // TEST
    func testNotification() {
        
        let userInfo = ["title":"Uitnodiging gesprek", "message":"Je opdracht via iCasting begint over twee dagen. Mocht je nog advies of hulp nodig hebben, neem dan contact op met support@icasting.com. Succes!"]
        
        let notificationView = NSBundle.mainBundle().loadNibNamed("NotificationView",
            owner: self, options: nil)[0] as! NotificationView
        notificationView.title.text = userInfo["title"]
        notificationView.message.text = userInfo["message"]
        
        let notification = CWStatusBarNotification()
        notification.notificationLabelBackgroundColor = UIColor.darkGrayColor()
        notification.notificationStyle = CWNotificationStyle.NavigationBarNotification
        //notification.displayNotificationWithMessage(message, forDuration: 4.0)
        notification.displayNotificationWithView(notificationView, forDuration: 20.0)
        notification.notificationTappedBlock = {
            notification.dismissNotification()
            
            
            NSNotificationCenter.defaultCenter().postNotificationName(kReceivedRemoteNotificationKey, object: nil, userInfo: userInfo)
        }
    }
    
    
    func registrationHandler(registrationToken: String!, error: NSError!) {

        if (registrationToken != nil) {
            self.registrationToken = registrationToken
            println("AppDelegate: Registration Token: \(registrationToken)")
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

    
    func onTokenRefresh() {
        
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        println("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM,
            options: registrationOptions,
            handler: registrationHandler)
    }
    
    func saveGCMRegistrationToken(token: String) {

        println("AppDelegate: GCM token will be saved")
        PushToken.token = token
    }

    /*func saveAPNSDeviceToken(token: NSData) {
    
    PushToken.token = PushNotificationDevice.convertDeviceTokenToHexadecimal(token)
    }*/
 
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