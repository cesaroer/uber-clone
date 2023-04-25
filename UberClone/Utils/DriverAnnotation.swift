//
//  DriverAnnotation.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 24/04/23.
//

import Foundation
import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var uid : String
    
    init(coordinate: CLLocationCoordinate2D, uid: String) {
        self.coordinate = coordinate
        self.uid = uid
    }
    
}
