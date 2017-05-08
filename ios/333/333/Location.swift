//
//  Location.swift
//  333
//
//  Created by Victor Zhou on 5/8/17.
//  Copyright © 2017 333. All rights reserved.
//

import Foundation
import CoreLocation

class Location: NSObject, CLLocationManagerDelegate {
    static let sharedInstance = Location()
    
    let locationManager = CLLocationManager()
    var lat: Float = 0
    var long: Float = 0
    
    private var success: (() -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestAuth(success: @escaping () -> Void, failure: () -> Void) {
        // Check if location services are enabled.
        if CLLocationManager.locationServicesEnabled() {
            // Request location authorization.
            self.success = success
            locationManager.requestWhenInUseAuthorization()
        } else {
            failure()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways {
            print("Location Authorized.")
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            lat = Float(locationManager.location!.coordinate.latitude)
            long = Float(locationManager.location!.coordinate.longitude)
            if let s = success {
                s()
                success = nil
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            lat = Float(loc.coordinate.latitude)
            long = Float(loc.coordinate.longitude)
        }
    }
}
