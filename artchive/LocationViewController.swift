//
//  LocationViewController.swift
//  artchive
//
//  Created by Jason Cheng on 1/13/15.
//  Copyright (c) 2015 oceanapart. All rights reserved.
//

import UIKit
import CoreLocation
import QuadratTouch

class LocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    
    var selectedVenue:Venue?
    private var locationManager:CLLocationManager!
    private var session: Session!
    private var venues:[Venue]!
    
    @IBOutlet weak var currentLocationLabel: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBAction func saveLocation(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Hide status bar
        UIApplication.sharedApplication().statusBarHidden = true
        
        venues = [Venue]()
        
        // LocationManager init
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        else if status == .AuthorizedWhenInUse || status == .Authorized {
            loadingIndicator.startAnimating()
            locationManager.startUpdatingLocation()
        }
        else {
            showNoPermissionAlert()
        }
        
        // Foursquare Api session
        session = Session.sharedSession()
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        println("\(locValue.longitude) \(locValue.latitude)")
        
        
        reverseGeocode(manager.location)
        browseVenues()
        
        // Stop location service after coordinate is received
        locationManager.stopUpdatingLocation()
    }
    
    // Get the address of the current GPS location and set that to location label
    func reverseGeocode(location:CLLocation){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location , completionHandler: {
            (placemarks, error) in
            var placemark:CLPlacemark = placemarks.last as CLPlacemark
            println("address: \(placemark.thoroughfare)")
            self.currentLocationLabel.text = placemark.thoroughfare
        })
    }
    
    func browseVenues() {
        var parameters:Parameters = Parameters()
        let longitude = locationManager.location.coordinate.longitude
        let latitude = locationManager.location.coordinate.latitude
        parameters.updateValue("\(longitude),\(latitude)", forKey: Parameter.ll)
//        parameters.updateValue("42.339878,-71.094536", forKey: Parameter.ll)
//        parameters.updateValue("browse", forKey: Parameter.intent)
//        parameters.updateValue("2000", forKey: Parameter.radius)
        parameters.updateValue("Arts", forKey: Parameter.query)
        
        let task = session.venues.explore(parameters,
            completionHandler: { (result) -> Void in
                self.venues = [Venue]()
                
                let json = JSON(result.response!)
                for (index: String, item: JSON) in json["groups"][0]["items"] {
                    var venue:Venue = Venue(name: item["venue"]["name"].stringValue, address: item["venue"]["location"]["address"].stringValue)
                    self.venues.append(venue)
                }
                
                self.tableView.reloadData()
                self.loadingIndicator.stopAnimating()
        })
        
        task.start()
    }
    
    // didFailWithError
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        showErrorAlert(error)
    }
    
    // didChangeAuthorizationStatus
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        // If permission becomes denied or restricted ask for permission
        if status == .Denied || status == .Restricted {
            showNoPermissionAlert()
        }
        // Start tracking location again after status went from restricted/denied to ok
        else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func showNoPermissionAlert(){
        var alert = UIAlertController(title: "Oops", message: "In order to work, app needs your location", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Open settings", style: .Default, handler: {
            (alertAction) in
            
            let URL = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(URL!)
            
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(error: NSError){
        var alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {
            (alertAction) in

            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as LocationTableViewCell
        let venue = venues[indexPath.row]
        cell.nameLabel.text = venue.name
        cell.addressLabel.text = venue.address
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let venue = venues[indexPath.row]
        self.selectedVenue = venue
        
        self.performSegueWithIdentifier("unwindToAddArtwork", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//        println("sup")
//    }
    

}
