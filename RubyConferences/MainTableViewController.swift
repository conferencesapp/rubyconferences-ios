//
//  MainTableViewController.swift
//  RubyConferences
//
//  Created by Rashmi Yadav on 5/1/15.
//
//

import UIKit
import Alamofire


class MainTableViewController: UITableViewController {
    let CellIdentifier = "cell"
    var conferencesData = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "reloadData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        
        getConferences()
    }
    
    func getConferences(){
        Alamofire.request(.GET, "https://rubyconferences.herokuapp.com/api/v1/conferences", parameters: ["foo": "bar"])
            .responseJSON { (request, response, data, error) in
                var resultData: NSArray = data as! NSArray
                self.processResults(resultData)
        }
        
    }

    func processResults(data: NSArray) -> Void{
        self.conferencesData = data
        self.tableView.reloadData()
    }
    
    func reloadData(){
        self.refreshControl?.endRefreshing()
        getConferences()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var count: Int = self.conferencesData.count > 0 ? 1 : 0
        return count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var row_count: Int = self.conferencesData.count > 0 ? self.conferencesData.count : 0
        return row_count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        var conferenceInfo = Conference(data: conferencesData[indexPath.row] as! NSDictionary)
        
        var image_url = NSURL(string: conferenceInfo.image_url)
        var data = NSData(contentsOfURL: image_url!)
        var conferenceImage: UIImage? = UIImage(data: data!)
        
        var ImageView: UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        ImageView.image = conferenceImage
        
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void{
        var websiteLink: String = conferencesData[indexPath.row]["website"] as! String
        var websiteUrl: NSURL? = NSURL(string: websiteLink)
        
        UIApplication.sharedApplication().openURL(websiteUrl!)
        
    }
}
