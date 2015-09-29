//
//  MainTableViewController.swift
//  ConferencesApp
//
//  Created by Rashmi Yadav on 5/1/15.
//
//

import UIKit
import Alamofire
import RealmSwift
import Haneke

class MainTableViewController: UITableViewController {
    let CellIdentifier = "cell"
    
    var conferencesData = []
    var conferences:[Conference] =  []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "reloadData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        
        if Reachability().connectedToNetwork() {
            getConferencesFromApi()
        }
    }
    
    func getConferencesFromApi(){
        let authorizationToken = "Token token=\(apiSecret)"
        
        let headers = ["Authorization": authorizationToken]
        
        Alamofire.request(.GET, "\(apiUrl)/conferences?tags=ruby", headers: headers)
            .responseJSON { (request, response, result) in
                switch result {
                case .Success(let JSON):
                     let resultData: NSArray = JSON as! NSArray
                     self.processResults(resultData)
                    
                case .Failure(let data, let error):
                    print("Request failed with error: \(error)")
                    
                    if let data = data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }
        
    }

    func processResults(data: NSArray) -> Void{
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
          }
          //delete expired confs
           for(id) in removableIds{
                let deleteConf = realm.objects(Conference).filter("id= \(id)")
                realm.delete(deleteConf)
            }
        }catch{
          print("Error")
      }
        
        self.tableView.reloadData()
    }
    
    func formatTwitterUsername(username: String) -> String{
        var twitter: String = username
            
        if twitter != ""{
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
    
    func getLocalIds() -> Set<Int>{
        var localIds =  Set<Int>()
        for(lconf) in Conference.findAll(){
            localIds.insert(lconf["id"] as! Int)
        }
        
        return localIds
    }
    
    func getServerIds() -> Set<Int>{
        var serverIds =  Set<Int>()
        for(sconf) in self.conferencesData{
            serverIds.insert(sconf["id"] as! Int)
        }
        
        return serverIds
    }
    
    func reloadData(){
        if Reachability().connectedToNetwork() {
            getConferencesFromApi()
        }
        else{
            let alert = UIAlertView(title: "No Internet connection", message: "Please ensure you are connected to the Internet", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        self.refreshControl?.endRefreshing()
    }
    
    func deleteAll(){
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conferences = Conference.findAll()
        let row_count: Int = conferences.count > 0 ? conferences.count : 0
        return row_count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)
      
        let conferenceInfo = conferences[indexPath.row]
        let imageView: UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        let logo_url = NSURL(string: conferenceInfo.logo_url)!
        imageView.hnk_setImageFromURL(logo_url)
        
        let title: UILabel = cell.contentView.viewWithTag(101) as! UILabel
        title.text = conferenceInfo.name
        
        let twitter: UILabel = cell.contentView.viewWithTag(102) as! UILabel
        twitter.text = conferenceInfo.twitter_username
        
        let location: UILabel = cell.contentView.viewWithTag(103) as! UILabel
        location.text = conferenceInfo.place
        
        let when: UILabel = cell.contentView.viewWithTag(104) as! UILabel
        when.text = conferenceInfo.when
        
        return cell
    
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if(self.tableView.respondsToSelector(Selector("setSeparatorInset:"))){
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        
        if(self.tableView.respondsToSelector(Selector("setLayoutMargins:"))){
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        if(cell.respondsToSelector(Selector("setLayoutMargins:"))){
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        cell.preservesSuperviewLayoutMargins = false
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }   
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)  {
        if segue.identifier == "viewConference" {
            let selectedRow = tableView.indexPathForSelectedRow?.row
            let viewController = segue.destinationViewController as! ConferenceTableViewController

            viewController.conference = Conference.findAll()[selectedRow!]
        }
    }
}
