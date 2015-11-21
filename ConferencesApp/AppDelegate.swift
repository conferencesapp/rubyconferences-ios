
//
//  AppDelegate.swift
//  ConferencesApp
//
//  Created by Rashmi Yadav on 5/1/15.
//
//

import UIKit
import Alamofire
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let type: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound]
        let pushSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: type, categories: nil)
        application.registerUserNotificationSettings(pushSettings)
        application.registerForRemoteNotifications()
      
        updateMigration()
        
        return true
    }

    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        print("device token string \(deviceTokenString)")
        sendDevicetokentoServer(deviceTokenString)
    }
    
    func sendDevicetokentoServer(deviceTokenString: String) {
        let parameters = [
            "device":
                [
                    "token": deviceTokenString
            ]
        ]
        
        var JSONSerializationError: NSError? = nil
        let URL = NSURL(string: apiUrl)!
        let path = "/v1/devices"
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = "POST"
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch let error as NSError {
            JSONSerializationError = error
            mutableURLRequest.HTTPBody = nil
        }
        mutableURLRequest.setValue("Token token=\(apiSecret)", forHTTPHeaderField: "Authorization")
        
        Alamofire.request(Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0)
    }
    
    func updateMigration() -> Void {
      let config = Realm.Configuration(
        schemaVersion: 4,
        
        // Set the block which will be called automatically when opening a Realm with
        // a schema version lower than the one set above
        migrationBlock: { migration, oldSchemaVersion in
          if (oldSchemaVersion < 1) {
          }
      })
      
      // Tell Realm to use this new configuration object for the default Realm
      Realm.Configuration.defaultConfiguration = config
    }
    
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(userInfo["id"])
        var id: Int = userInfo["id"] as! Int
        print(id)
        
        let realm = try! Realm()
        var conference = realm.objects(Conference).filter("id=\(id)")[0]
        var segue = UIStoryboard(name: "Main", bundle: nil)
        var viewController = segue.instantiateViewControllerWithIdentifier("ConferenceTableViewController") as!ConferenceTableViewController
        var rootViewController = self.window!.rootViewController as! UINavigationController
        viewController.conference = conference
       // rootViewController.navigationController?.popViewController(viewController, animated: true)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        print(conference)
        
        if ( application.applicationState == UIApplicationState.Inactive || application.applicationState == UIApplicationState.Background  )
        {
            

        }
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data stack
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.jqsoftware.MyLog" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
}

