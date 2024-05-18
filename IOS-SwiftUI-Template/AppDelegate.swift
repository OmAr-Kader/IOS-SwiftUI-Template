import Foundation
import SwiftUI

//https://github.com/firebase/quickstart-ios/blob/master/messaging/MessagingExampleSwift/AppDelegate.swift

class AppDelegate: NSObject, UIApplicationDelegate {
    private(set) var appSet: AppObserve! = nil
    
    var app: AppObserve {
        guard let appSet else {
            let app = AppObserve()
            self.appSet = app
            return app
        }
        return appSet
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        appSet = nil
    }

}


/*
import FirebaseCore
import FirebaseMessaging
//https://github.com/firebase/quickstart-ios/blob/master/messaging/MessagingExampleSwift/AppDelegate.swift

class AppDelegate: NSObject, UIApplicationDelegate {
    static private(set) var del: AppDelegate! = nil
    private(set) var appSet: AppModule! = nil
    private(set) var prefSet: PrefObserve! = nil
    
    var app: AppModule {
        guard let appSet else {
            let ap = AppModule()
            self.appSet = ap
            return ap
        }
        return appSet
    }
    
    var pref: PrefObserve {
        guard let prefSet else {
            let pre = PrefObserve(
                app,
                Theme(isDarkMode: UITraitCollection.current.userInterfaceStyle.isDarkMode)
            )
            self.prefSet = pre
            return pre
        }
        return prefSet
    }
        
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        AppDelegate.del = self
        application.registerForRemoteNotifications()
        FirebaseApp.configure()

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
/*
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        */
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        appSet = nil
        prefSet = nil
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        /*if let messageID = userInfo[gcmMessageIDKey] {
         print("Message ID: \(messageID)")
         }*/
        /*let n = PushNotification.init(info: userInfo)

        print(userInfo)
        print(n)
*/
        // Print full message.
        print(userInfo)
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        /*if let messageID = userInfo[gcmMessageIDKey] {
         print("Message ID: \(messageID)")
         }*/
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    /*
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }*/
}*/
