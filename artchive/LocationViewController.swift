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

class LocationViewController: UIViewController, CLLocationManagerDelegate{
    let locationManager = CLLocationManager()
    private var session: Session!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Hide status bar
        UIApplication.sharedApplication().statusBarHidden = true
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
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
        println("\(locValue.longitude)")
        
        browseVenues()
        
        // Stop location service after coordinate is received
        locationManager.stopUpdatingLocation()
    }
    
    func browseVenues() {
        var parameters:Parameters = Parameters()
        let longitude = locationManager.location.coordinate.longitude
        let latitude = locationManager.location.coordinate.latitude
        parameters.updateValue("\(longitude),\(latitude)", forKey: Parameter.ll)
//        parameters.updateValue("42.338,-71", forKey: Parameter.ll)
//        parameters.updateValue("browse", forKey: Parameter.intent)
//        parameters.updateValue("1000", forKey: Parameter.radius)
        parameters.updateValue("arts", forKey: Parameter.section)
        parameters.updateValue("20", forKey: Parameter.limit)
        
        let task = session.venues.explore(parameters,
            completionHandler: { (result) -> Void in
                print(result)
        })
        
        task.start()
    }
    
    // didFailWithError
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
    }
    
    // didChangeAuthorizationStatus
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
