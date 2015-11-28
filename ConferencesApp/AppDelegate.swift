
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
import Intercom

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let type: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound]
        let pushSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: type, categories: nil)
        application.registerUserNotificationSettings(pushSettings)
        application.registerForRemoteNotifications()
      
        Intercom.setApiKey((intercomApiKey), forAppId: (intercomAppId))
        Intercom.registerUnidentifiedUser()
        updateMigration()
        
        return true
    }

    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
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
        schemaVersion: 5,
        
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
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void){
        if(application.applicationState == .Background || application.applicationState == .Inactive){
            
            let id: Int = userInfo["id"] as! Int
            
            let realm = try! Realm()
            let conference = realm.objects(Conference).filter("id=\(id)")[0]
            let segue = UIStoryboard(name: "Main", bundle: nil)
            let viewController = segue.instantiateViewControllerWithIdentifier("ConferenceTableViewController") as!ConferenceTableViewController
            let rootViewController = self.window!.rootViewController as! UINavigationController
            
            viewController.conference = conference
            
            rootViewController.popToRootViewControllerAnimated(true)
            rootViewController.pushViewController(viewController, animated: true)            
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.jqsoftware.MyLog" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
}

