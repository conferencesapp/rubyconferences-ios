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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "reloadData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        
        if Reachability.isConnectedToNetwork() {
            getConferencesFromApi()
        }
    }
    
    func getConferencesFromApi(){        
        let authorizationToken = "Token token=\(apiSecret)"
        
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["Authorization": authorizationToken]

        Alamofire.request(.GET, "\(apiUrl)/conferences?tags=ruby")
            .responseJSON { (request, response, data, error) in
                var resultData: NSArray = data as! NSArray
                self.processResults(resultData)
        }
        
    }

    func processResults(data: NSArray) -> Void{
        self.conferencesData = data
        
        var localIds: Set<Int> =  getLocalIds()
        var serverIds: Set<Int> = getServerIds()
        var removableIds = localIds.subtract(serverIds)
        
        let realm = Realm()
        
        realm.write {
          for(data) in self.conferencesData {
            var conf = Conference()
            conf.id = data["id"] as! Int!
            conf.name = data["name"] as! String!
            conf.detail = "This is description a very long description. We are pleases to announce Ruby Raven which is an iOS app that will keep you updated about latest happening in Ruby Conferences world."//data["description"] as! String!
            conf.location = data["location"] as! String
            
            conf.twitter_username = self.formatTwitterUsername(data["twitter_username"] as! String)
            
            let logos: NSDictionary = data["logos"] as! NSDictionary!
            conf.logo_url  =  logos["thumb"] as! String!
            conf.image_url =  logos["logo"] as! String!

            conf.place = data["location"] as! String!
            conf.when = data["when"] as! String!

            conf.latitude = data["latitude"] as! Double!
            conf.longitude = data["longitude"] as! Double!

            if let ws = data["website"] as? String{
                conf.website = ws
            }
            conf.startDate = self.formatStartdate(data["start_date"] as! String)
            realm.add(conf, update: true)
          }
            
          //delete expired confs
           for(id) in removableIds{
                var deleteConf = realm.objects(Conference).filter("id= \(id)")
                realm.delete(deleteConf)
            }
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
        var dateString = stareDate// change to your date format
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var date = dateFormatter.dateFromString(dateString)
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
        if Reachability.isConnectedToNetwork() {
            getConferencesFromApi()
        }
        else{
            var alert = UIAlertView(title: "No Internet connection", message: "Please ensure you are connected to the Internet", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        self.refreshControl?.endRefreshing()
    }
    
    func deleteAll(){
        let realm = Realm()
        realm.write {
            realm.deleteAll()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var count: Int = Conference.findAll().count > 0 ? 1 : 0
        return count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var row_count: Int = Conference.findAll().count > 0 ? Conference.findAll().count : 0
        return row_count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! UITableViewCell
    
        var conferenceInfo = Conference.findAll()[indexPath.row]
        var imageView: UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        let logo_url = NSURL(string: conferenceInfo.logo_url)!
        imageView.hnk_setImageFromURL(logo_url)
        
        var title: UILabel = cell.contentView.viewWithTag(101) as! UILabel
        title.text = conferenceInfo.name
        
        var twitter: UILabel = cell.contentView.viewWithTag(102) as! UILabel
        twitter.text = conferenceInfo.twitter_username
        
        var location: UILabel = cell.contentView.viewWithTag(103) as! UILabel
        location.text = conferenceInfo.place
        
        var when: UILabel = cell.contentView.viewWithTag(104) as! UILabel
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
            let selectedRow = tableView.indexPathForSelectedRow()?.row
            let viewController = segue.destinationViewController as! ConferenceTableViewController

            viewController.conference = Conference.findAll()[selectedRow!]
        }
    }
}
