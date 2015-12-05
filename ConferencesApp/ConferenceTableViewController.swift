//
//  ConferenceTableViewController.swift
//  ConferencesApp
//
//  Created by Rashmi Yadav on 7/25/15.
//
//

import UIKit
import MapKit
import Haneke
import AddressBook
import EventKit

class ConferenceTableViewController: UITableViewController, MKMapViewDelegate {
    var conference = Conference()
    var conferenceDataStore: ConferenceDataStore?
    var conferenceName: String!
    var startDate: NSDate!
    var endDate: NSDate!
    var calendarEventID: String!

    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var proposalImage: UIImageView!
    @IBOutlet weak var proposalLabel: UILabel!
    
    @IBOutlet weak var dateImage: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    
    @IBOutlet weak var twitterImageButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: conference.image_url)
        
        logoImage.hnk_setImageFromURL(url!)
        nameLabel.text = conference.name
        proposalLabel.text = conference.cfp_text
        dateLabel.text = conference.when
        locationLabel.text = conference.location

        conferenceName = conference.name
        startDate =  conference.startDate
        endDate = conference.endDate
        calendarEventID = conferenceDataStore?.calendarEventIDFor(conference)
        dateImage.userInteractionEnabled = true

        setTapGestureOnDateImage()

        twitterButton.setTitle(conference.twitter_username, forState: .Normal)
        twitterImageButton.addTarget(self, action: "openTwitterApp", forControlEvents: .TouchUpInside)
        showMap(conference)
    }

    func showMap(conference: Conference) -> Void {
        let theRegion = setMapCoordinates()
        
        self.mapView.setRegion(theRegion, animated: true)
        
        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = theRegion.center
        mapAnnotation.title = conference.location

        mapView.addAnnotation(mapAnnotation)
        mapView.selectAnnotation(mapAnnotation, animated: true)
        
        let tapGesture = setGesture()
        mapView.addGestureRecognizer(tapGesture)
    }

    func setGesture() -> UITapGestureRecognizer
    {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.addTarget(self, action: "handleTap:")

        return tapGesture
    }

    func handleTap(sender: UITapGestureRecognizer) -> Void{
        let mapView = sender.view as! MKMapView!

        let coordinate = mapView.region.center
        let location  = conference.location
        //var span = mapView.region.span
        
        let regionDistance:CLLocationDistance = 0.1
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinate, regionDistance, regionDistance)
        


        let addressDictionary = [String(kABPersonAddressStreetKey): location]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        

        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location

       
        let launchOptions = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        
        mapItem.openInMapsWithLaunchOptions(launchOptions)
    }

    func setMapCoordinates() -> MKCoordinateRegion {
        let latitude: CLLocationDegrees = conference.latitude
        let longitude: CLLocationDegrees = conference.longitude

        let latDelta: CLLocationDegrees = 0.05
        let longDelta: CLLocationDegrees = 0.05
       
        

        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let venueLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
                let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(venueLocation, theSpan)

        return theRegion
    }

    func setTapGestureOnDateImage() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.addTarget(self, action: "tapOnDateImageHandler:")
        dateImage.addGestureRecognizer(tapGesture)
    }

    func tapOnDateImageHandler(sender: UITapGestureRecognizer) {
        let eventStore = EKEventStore()

        eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
            granted, error in
            if (granted) && (error == nil) {
                if self.calendarEventID.isEmpty {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.addCalendarEventtoStore(eventStore)
                    }
                } else { // Event Already present in calendar.
                    dispatch_async(dispatch_get_main_queue()) {
                        self.deleteEventFromStore(eventStore, eventID:self.calendarEventID)
                    }
                }
            }
        })
    }

    func addCalendarEventtoStore(eventStore: EKEventStore) {
        let event: EKEvent = EKEvent(eventStore: eventStore)
        event.title = self.conferenceName
        event.startDate = self.startDate
        event.endDate = self.endDate
        event.location = self.locationLabel.text
        event.allDay = true

        event.calendar = eventStore.defaultCalendarForNewEvents

        let alertController = UIAlertController(title: "Create Event.",
            message: "Would you like to add \(conference.name) event in your calender?", preferredStyle: .Alert)

        let createAction = UIAlertAction(title: "Create", style: .Default) { (action) -> Void in
            do {
                try eventStore.saveEvent(event, span: EKSpan.ThisEvent, commit: true)
                self.calendarEventID = event.eventIdentifier

                self.conferenceDataStore?.updateCalendarEventIdentifier(self.conference,
                    eventId:event.eventIdentifier)
            } catch {
                print("Failed to create an event in Calendar.")
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler:nil )

        alertController.addAction(createAction)
        alertController.addAction(cancelAction)

        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func deleteEventFromStore(eventStore: EKEventStore, eventID: String) {
        if let event = eventStore.eventWithIdentifier(eventID) {
            let alertController = UIAlertController(title: "Delete Event.",
                message: "Would you like to remove \(conference.name) event from your calendar?", preferredStyle: .Alert)

            let deleteAction = UIAlertAction(title: "Delete", style: .Default) { (action) -> Void in
                do {
                    try eventStore.removeEvent(event, span: EKSpan.ThisEvent, commit: true)
                } catch _ {
                    print("Failed to delete event")
                }

                self.calendarEventID = ""
                self.conferenceDataStore?.updateCalendarEventIdentifier(
                    self.conference, eventId:"")
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler:nil )

            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)

            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            // Could not find event, so delete Event Data.
            // This can happen if user has deleted event manually from calendar.
            self.conferenceDataStore?.deleteCalendarEventData(self.conference)
            self.calendarEventID = ""
        }
    }

    func openTwitterApp(){
        let twitterName = conference.twitter_username
        var URL = ""
        var URLInApp = ""
        URL = "https://twitter.com/" + conference.twitter_username
        URLInApp = "twitter://user?screen_name=\(twitterName)"
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: URLInApp)!) {
            UIApplication.sharedApplication().openURL(NSURL(string: URLInApp)!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: URL)!)
        }
    }
    
    @IBAction func openTwitter(sender: UIButton) {
        openTwitterApp()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)  {
        if segue.identifier == "webView" {
           // let selectedRow = tableView.indexPathForSelectedRow?.row
            let viewController = segue.destinationViewController as! ConferenceWebViewController

            viewController.conferenceLink = conference.website
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.allowsSelection = false
        
    }
}
