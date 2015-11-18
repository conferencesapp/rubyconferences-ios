//
//  MainTableViewController.swift
//  ConferencesApp
//
//  Created by Rashmi Yadav on 5/1/15.
//
//

import UIKit
import Haneke

class MainTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!

    var conferences:[Conference] =  []
    var conferencesGroup = OrderedDictionary<String, [Conference]>()
    var filterConferencesGroup =  OrderedDictionary<String, [Conference]>()
    let CellIdentifier = "cell"
    var filterConferences: [Conference] = []
    var conferenceDataStore = ConferenceDataStore()
    var searchActive : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "reloadData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        searchBar.delegate = self
        searchBar.tintColor = UIColor(white:0.5, alpha: 1.5)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ConferencesUpdatedNotificationHandler:",
            name:"ConferencesUpdatedNotification", object: nil)

        if Reachability().connectedToNetwork() {
            conferenceDataStore.getConferencesFromApi()
        }
    }

    func reloadData() {
        if Reachability().connectedToNetwork() {
            conferenceDataStore.getConferencesFromApi()
        } else {
            let alert = UIAlertView(title: "No Internet connection", message: "Please ensure you are connected to the Internet", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }

    dynamic func ConferencesUpdatedNotificationHandler(notification: NSNotification) {
        conferences = conferenceDataStore.findAll()
        conferencesGroup = conferenceDataStore.groupByDate(conferences)

        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }

    func conferenceRow(section: Int, row: Int) -> Conference {
        let values = conferencesData()[section].1

        return values[row]
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
        if(searchBar.text!.isEmpty){
            searchActive = false
        }
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
        self.searchBar.endEditing(true)
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        self.searchBar.text = ""
        self.searchBar.endEditing(true)
        
        self.tableView.reloadData()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        self.searchBar.endEditing(true)

        self.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            searchActive = false
            searchBar.endEditing(false)
        }else{
            filterConferences = conferenceDataStore.filterConferences(searchText, conferences: conferences)
            filterConferencesGroup = conferenceDataStore.groupByDate(filterConferences)

            if(filterConferences.count == 0){
                searchActive = false
            } else {
                searchActive = true
            }
            self.tableView.reloadData()
        }
    }

    func conferencesData() -> OrderedDictionary<String, [Conference]>{
        if(searchActive){
            return filterConferencesGroup
        }else{
            return conferencesGroup
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return conferencesData().array.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let row_count: Int = conferencesData()[section].1.count

        return row_count
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("headerCell") as! CustomHeaderCell
        headerCell.headerLabel.sizeToFit()
        headerCell.headerLabel.text = conferencesData()[section].0

        return headerCell
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)

        let conferenceInfo = conferenceRow(indexPath.section, row: indexPath.row)

        let imageView: UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        let logo_url = NSURL(string: conferenceInfo.logo_url)!
        imageView.hnk_setImageFromURL(logo_url)

        let title: UILabel = cell.contentView.viewWithTag(101) as! UILabel
        title.text = conferenceInfo.name

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
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36.0
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)  {
        if segue.identifier == "viewConference" {
            let selectedRow = tableView.indexPathForSelectedRow?.row
            let section = tableView.indexPathForSelectedRow?.section

            let conferenceInfo = conferenceRow(section!, row: selectedRow!)

            let viewController = segue.destinationViewController as! ConferenceTableViewController
            viewController.conference = conferenceInfo
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
