//
//  HomeController.swift
//  UberClone
//
//  Created by Cesar Vargas on 24/09/21.
//

import UIKit
import Firebase
import MapKit

class HomeController: UIViewController {
    
    
    //MARK: - Properties
    private let mapView = MKMapView()
    static let NotificationDone = NSNotification.Name(rawValue: "Done")
    private let locationManager = CLLocationManager()
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
        //signOut()
        enableLocationServices()
    }
    
    //MARK: - API
    
    func checkIfUserIsLoggedIn() {
        if( Auth.auth().currentUser?.uid == nil) {
            print("DEBUG: User not logger In")
            DispatchQueue.main.async {
                NotificationCenter.default
                    .post(name: HomeController.NotificationDone, object: nil)
            }
        }else {
            configureUI()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        }catch let error {
            print("DEBUG: Error \(error.localizedDescription)")
        }
    }
    
    //MARK: - Helpers
    func configureUI() {
        configureMapView()
    }

    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
}


//MARK: - LocationServices
extension HomeController: CLLocationManagerDelegate {
    
    func enableLocationServices() {
        
        locationManager.delegate = self
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("DEBUG: notDetermined")
            locationManager.requestWhenInUseAuthorization()
        case .restricted,.denied:
            break
        case .authorizedAlways:
            print("DEBUG: authorizedAlways")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: authorizedWhenInUse")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}
