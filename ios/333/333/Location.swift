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
    
    private let locationManager = CLLocationManager()
    var lat: Float = 0
    var long: Float = 0
    
    private var success: (() -> Void)?
    
    override private init() {
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

    func hasLocationAuth() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways
    }

    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if hasLocationAuth() {
            print("Location Authorized.")
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            if let loc = locationManager.location {
                lat = Float(loc.coordinate.latitude)
                long = Float(loc.coordinate.longitude)
            }
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
