//
//  LocationHandler.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 24/04/23.
//

import Foundation
import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate {
    //MARK: - Properties
    static let shared = LocationHandler()
    var locationManager: CLLocationManager!
    var location: CLLocation?

    //MARK: - LifeCycle
    init(locationManager: CLLocationManager = CLLocationManager(),
         location: CLLocation? = nil) {
        super.init()
        self.locationManager = locationManager
        self.locationManager.delegate = self
        self.location = location
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
}
