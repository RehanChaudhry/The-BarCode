//
//  MyLocationManager.swift
//  GPSCash-iOS-V2
//
//  Created by Mac OS X on 21/08/2017.
//  Copyright © 2017 Cygnis Media. All rights reserved.
//

import UIKit
import CoreLocation

let MyLocationManagerErrorDomain = "MyLocationManagerErrorDomain"
typealias LocationRequestResult = ((_ location: CLLocation?, _ error: NSError?) -> Void)

enum MyLocationManagerError: Int {
    case denied = 5000
    case restricted = 5001
    case timedOut = 5002
    case unknown = 5003
}

class MyLocationManager: NSObject {
    
    var locationManager: CLLocationManager!
    
    var locationRequestResult: LocationRequestResult?
    
    var timeOutInterval: TimeInterval = 20.0
    
    var locationPreferenceAlways = true

    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(timedOut), object: nil)
    }
    
    func requestLocation(desiredAccuracy: CLLocationAccuracy, timeOut: TimeInterval, result: @escaping LocationRequestResult) {
        
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = desiredAccuracy
        self.locationManager.delegate = self
        
        self.locationRequestResult = result
        self.timeOutInterval = timeOut
        
        if locationPreferenceAlways {
            self.locationManager.requestAlwaysAuthorization()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
        self.perform(#selector(timedOut), with: nil, afterDelay: self.timeOutInterval)
    }
    
    func stopUpdatingLocationWithStatus(location: CLLocation?, error: NSError?, isCancelled: Bool) {
        
        defer {
            self.locationRequestResult = nil
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(timedOut), object: nil)
        self.locationManager.stopUpdatingLocation()
        
        guard isCancelled == false else {
            return
        }
        
        guard error == nil else {
            
            if CLLocationManager.authorizationStatus() == .denied {
                let errorMessage = "Please enable location services for The Bar Code in settings"
                let errorCode = MyLocationManagerError.denied
                let error = NSError(domain: MyLocationManagerErrorDomain, code: errorCode.rawValue, userInfo: [NSLocalizedDescriptionKey : errorMessage])
                locationRequestResult?(nil, error)
            } else if CLLocationManager.authorizationStatus() == .restricted {
                let errorMessage = "Location access is restricted"
                let errorCode = MyLocationManagerError.restricted
                let error = NSError(domain: MyLocationManagerErrorDomain, code: errorCode.rawValue, userInfo: [NSLocalizedDescriptionKey : errorMessage])
                locationRequestResult?(nil, error)
            } else {
                locationRequestResult?(nil, error)
            }

            return
        }
        
        locationRequestResult?(location!, nil)
    }
    
    @objc func timedOut() {
        let errorCode = MyLocationManagerError.timedOut
        let error = NSError(domain: MyLocationManagerErrorDomain, code: errorCode.rawValue, userInfo: [NSLocalizedDescriptionKey : "Unable to determine current location"])
        stopUpdatingLocationWithStatus(location: nil, error: error, isCancelled: false)
    }
}

extension MyLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            startUpdatingLocation()
        } else if status == .denied || status == .restricted {
            let errorCode = MyLocationManagerError.unknown
            let error = NSError(domain: MyLocationManagerErrorDomain, code: errorCode.rawValue, userInfo: [NSLocalizedDescriptionKey : "Unable to determine current location"])
            stopUpdatingLocationWithStatus(location: nil, error: error, isCancelled: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        stopUpdatingLocationWithStatus(location: locations.last, error: nil, isCancelled: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stopUpdatingLocationWithStatus(location: nil, error: error as NSError, isCancelled: false)
    }
}
