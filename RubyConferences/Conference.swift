//
//  Conference.swift
//  RubyConferences
//
//  Created by Rashmi Yadav on 5/2/15.
//
//


import RealmSwift

class Conference: Object {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var location: String = ""
    dynamic var place: String = ""
    dynamic var image_url: String = ""
    dynamic var twitter_username: String = ""
    dynamic var website: String = ""
    dynamic var when: String? = ""
    dynamic var startDate: NSDate? = NSDate()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
