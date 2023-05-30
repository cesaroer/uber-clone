//
//  Trip.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 05/05/23.
//

import Foundation
import CoreLocation

enum TripState: Int {
    case requested
    case denied
    case accepted
    case driverArrived
    case inProgress
    case arrivedAtDestination
    case completed
}

struct Trip {
    var pickupCoords: CLLocationCoordinate2D!
    var destinationCoords: CLLocationCoordinate2D!
    var passengerUUID: String!
    var driverUUID:  String?
    var state: TripState!

    init(passengerUUID: String, dictionary: [String: Any]) {
        self.passengerUUID = passengerUUID

        if let pickupCoords = dictionary["pickupCoordinates"] as? NSArray {
            if let lat = pickupCoords[0] as? CLLocationDegrees,
               let long = pickupCoords[1] as? CLLocationDegrees {
                self.pickupCoords = CLLocationCoordinate2D(latitude: lat, longitude: long)
            }
        }

        if let destinationCoords = dictionary["destinationCoordinates"] as? NSArray {
            if let lat = destinationCoords[0] as? CLLocationDegrees,
               let long = destinationCoords[1] as? CLLocationDegrees {
                self.destinationCoords = CLLocationCoordinate2D(latitude: lat, longitude: long)
            }
        }
        
        self.driverUUID = dictionary["driverUUID"] as? String ?? ""
        if let state = dictionary["state"] as? Int {
            self.state = TripState(rawValue: state)
        }
    }
}


