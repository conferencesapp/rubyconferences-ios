//
//  CalendarEventData.swift
//  ConferencesApp
//
//  Created by Hemant on 30/10/15.
//
//

import RealmSwift

class CalendarEventData: Object {
    dynamic var id: Int = 0
    dynamic var eventID: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }  
}