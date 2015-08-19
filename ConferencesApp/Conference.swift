//
//  Conference.swift
//  ConferencesApp
//
//  Created by Rashmi Yadav on 5/2/15.
//
//


import RealmSwift

class Conference: Object {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var detail: String = ""
    dynamic var location: String = ""
    dynamic var place: String = ""
    dynamic var image_url: String = ""
    dynamic var logo_url: String = ""
    dynamic var twitter_username: String = ""
    dynamic var website: String = ""
    dynamic var when: String? = ""
    dynamic var startDate: NSDate? = NSDate()
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    class func findAll() -> [Conference] {
        var conferences: [Conference] = []
        for conf in Realm().objects(Conference).sorted("startDate") {
            conferences.append(conf)
        }
        
        return conferences
    }
}