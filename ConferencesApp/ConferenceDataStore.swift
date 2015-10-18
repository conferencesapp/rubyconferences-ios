//
//  ConferenceDataStore.swift
//  
//  Created by Rashmi Yadav on 5/2/15.
//
//
//

import RealmSwift
import Alamofire

class ConferenceDataStore {
    
    var conferencesData = []
    
    func getConferencesFromApi() {
        let authorizationToken = "Token token=\(apiSecret)"
        let headers = ["Authorization": authorizationToken]
        
        Alamofire.request(.GET, "\(apiUrl)/v2/conferences?tags=ruby", headers: headers)
            .responseJSON { (_, _, result) in
                switch result {
                case .Success(let JSON):
                    let resultData: NSArray = JSON as! NSArray
                    self.processResults(resultData)
                    NSNotificationCenter.defaultCenter().postNotificationName("ConferencesUpdatedNotification", object: nil)
                    
                case .Failure(let data, let error):
                    print("Request failed with error: \(error)")
                    
                    if let data = data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }
    }
    
    func processResults(data: NSArray) -> Void {
        self.conferencesData = data
        
        let localIds: Set<Int> =  getLocalIds()
        let serverIds: Set<Int> = getServerIds()
        let removableIds = localIds.subtract(serverIds)
        
        let realm = try! Realm()
        
        do{
            try realm.write {
                for(data) in self.conferencesData {
                    let conf = Conference()
                    conf.id = data["id"] as! Int!
                    conf.name = data["name"] as! String!
                    if let detail = data["description"] as? String {
                        conf.detail = detail
                    }
                    
                    conf.location = data["location"] as! String
                    
                    conf.twitter_username = self.formatTwitterUsername(data["twitter_username"] as! String)
                    
                    let logos: NSDictionary = data["logos"] as! NSDictionary!
                    conf.logo_url  =  logos["thumb"] as! String!
                    conf.image_url =  logos["logo"] as! String!
                    
                    conf.place = data["location"] as! String!
                    conf.when = data["when"] as! String!
                    
                    conf.latitude = data["latitude"] as! Double!
                    conf.longitude = data["longitude"] as! Double!
                    conf.cfp_text = data["cfp_status"] as! String!
                    
                    if let ws = data["website"] as? String{
                        conf.website = ws
                    }
                    
                    conf.startDate = self.formatStartdate(data["start_date"] as! String)
                    realm.create(Conference.self, value: conf, update: true)
                }
            
            //delete expired confs
                for(id) in removableIds{
                    let deleteConf = realm.objects(Conference).filter("id= \(id)")
                    realm.delete(deleteConf)
                }
            }
        } catch {
            print("Error")
        }
    }
    
    func formatTwitterUsername(username: String) -> String{
        var twitter: String = username
        
        if twitter != "" {
            twitter =  "@\(username)"
        }
        return twitter
    }
    
    func formatStartdate(stareDate: String) -> NSDate {
        let dateString = stareDate// change to your date format
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let date = dateFormatter.dateFromString(dateString)
        return date!
    }
    
    func getLocalIds() -> Set<Int> {
        var localIds =  Set<Int>()
        for(lconf) in findAll() {
            localIds.insert(lconf["id"] as! Int)
        }
        
        return localIds
    }
    
    func getServerIds() -> Set<Int> {
        var serverIds =  Set<Int>()
        for(sconf) in self.conferencesData {
            serverIds.insert(sconf["id"] as! Int)
        }
        
        return serverIds
    }
    
    func findAll() -> [Conference] {
        var conferences: [Conference] = []
        for conf in try! Realm().objects(Conference).sorted("startDate") {
            conferences.append(conf)
        }
        
        return conferences
    }
    
    func filterConferences(searchText: String) -> [Conference]{
        let conferences = self.findAll().filter({ (conference) -> Bool in
            let tmp: NSString = conference.name
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        
        return conferences
    }
    
    func deleteAll(){
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
}
