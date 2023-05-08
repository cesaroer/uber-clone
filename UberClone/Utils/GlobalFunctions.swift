//
//  GlobalFunctions.swift
//  UberClone
//
//  Created by Cesar Vargas on 23/09/21.
//

import UIKit
import MapKit


extension UITextField {
    
    
    func addToolBar() {
        
        let tb = UIToolbar()
        
        tb.barStyle = .black
        tb.isTranslucent = true
        
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        tb.setItems([doneBtn], animated: true)
        tb.isUserInteractionEnabled = true
        tb.sizeToFit()
        
        inputAccessoryView = tb
    }
    
    
    @objc func donePressed() {
        self.endEditing(true)
    }
}


//how to use for middle
 
///    let source = MKMapItem(coordinate: originCoords, name: "Source")
///    let middle = MKMapItem(coordinate: .init(latitude: 37.78988372529948,
///                                             longitude: -122.4118223797717), name: "Middle")
///    let destination = MKMapItem(coordinate: destinationCoordinates, name: "Destination")
///
///    MKMapItem.openMaps(
///      with: [source, middle,destination],
///      launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
///    )
func launchRouteOnMaps(from originCoords: CLLocationCoordinate2D,
                       to destinationCoords: CLLocationCoordinate2D) {
    let source = MKMapItem(coordinate: originCoords, name: "Source")
    let destination = MKMapItem(coordinate: destinationCoords, name: "Destination")
    MKMapItem.openMaps(
        with: [source,destination],
        launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
    )
}




