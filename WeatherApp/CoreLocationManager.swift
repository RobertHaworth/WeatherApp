//
//  CoreLocationManager.swift
//  WeatherApp
//
//  Created by Robert Haworth on 10/27/16.
//  Copyright © 2016 Robert Haworth. All rights reserved.
//

import UIKit
import CoreLocation

// TODO: Increase functionality by watching for significant location changes to auto-update new current location.
// TODO: Remove creation of currentLocation from here, possibly put within DataManager. (Should we allow users to remove this manually, or only automagically remove when denied CLLocationManager data access?)
// MARK: -


class CoreLocationManager: NSObject, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocationAuthorization() {
        print("requesting location authorization")
        
        // Make a placeholder for Current Location even though we can not get the coordinates yet.
        if DataManager.sharedInstance.currentLocation() == nil {
            DataManager.sharedInstance.newLocation(queryString: "", name: "Current Location")
        }
        
        switch CLLocationManager.authorizationStatus() {
            case .denied, .notDetermined, .restricted: locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse: requestLocation()
        }
    }
    
    // TODO: Setup error handling (At this point if user denies access, Current Location will exist but never be valid)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedWhenInUse, .authorizedAlways: requestLocation()
            default: print("What should I do if the user denies access?")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let gpsLocation = locations.first else {
            print("location not returned, but updated. Should not occur")
            return
        }
        
        if let location = DataManager.sharedInstance.currentLocation() {
            let priorLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            // Only update if gpsLocation is greater than 20 meters (arbitrary but stops from un-necessary changes)
            if gpsLocation.distance(from: priorLocation) > 20.0 {
                location.latitude = gpsLocation.coordinate.latitude
                location.longitude = gpsLocation.coordinate.longitude
            }
        }
        DataManager.sharedInstance.saveContext()
    }
    
    // TODO: Setup error handling
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("We need to handle locationManager errors in some manner")
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
}
