//
//  ConferenceItem.swift
//  
//
//  Created by Rashmi Yadav on 5/12/15.
//
//

import Foundation
import CoreData

class ConferenceItem: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var location: String
    @NSManaged var place: String
    @NSManaged var image_url: String
    @NSManaged var twitter_username: String
    @NSManaged var website: String
    @NSManaged var when: String?

    class func createInManagedObjectContext(moc: NSManagedObjectContext, data: NSDictionary) -> ConferenceItem {
        
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("ConferenceItem", inManagedObjectContext: moc) as! ConferenceItem
        newItem.name = data["name"] as! String!
        newItem.location = data["location"] as! String
        
        newItem.twitter_username = data["twitter_username"] as! String
        if newItem.twitter_username != ""{
            newItem.twitter_username =  "@\(newItem.twitter_username)"
        }
        
        
        newItem.image_url = data["image_url"] as! String!
        newItem.place = data["location"] as! String!
        newItem.when = data["when"] as! String!
        if let ws = data["website"] as? String{
            newItem.website = ws
        }

        
        return newItem
    }
    
}
