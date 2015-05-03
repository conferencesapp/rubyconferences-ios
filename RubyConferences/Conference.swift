//
//  Conference.swift
//  RubyConferences
//
//  Created by Rashmi Yadav on 5/2/15.
//
//

import Foundation

struct Conference {
    var name: String
    var location: String
    var twitter_username: String
    var image_url: String
    var place: String
    var when: String
    //    var description: String?
    
    init(data: NSDictionary){
        name = data["name"] as! String!
        location = data["location"] as! String
        
        twitter_username = data["twitter_username"] as! String
        if twitter_username != ""{
            twitter_username =  "@\(twitter_username)"
        }
        
    
        image_url = data["image_url"] as! String!
        place = data["location"] as! String!
        when = data["when"] as! String!
        //        description = conferenceData["description"] as! String!
    }
}
