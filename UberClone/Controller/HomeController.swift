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
    private let locationManager = CLLocationManager()
    static let NotificationDone = NSNotification.Name(rawValue: "Done")

    private let locationInputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    
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
        
        view.addSubview(locationInputActivationView)
        let viewWidht = self.view.frame.width - 64
        let firstX = (self.view.frame.width / 2) - (viewWidht / 2)
        
        locationInputActivationView.delegate = self
        locationInputActivationView.alpha = 0
        locationInputActivationView.frame = CGRect(x: firstX, y: 75,
                                                   width: viewWidht, height: 50)

        UIView.animate(withDuration: 1.5) {
            self.locationInputActivationView.alpha = 1
            self.locationInputActivationView.frame.origin.y = 90
        } completion: { _ in
            self.locationInputActivationView.centerX(inView: self.view)
            self.locationInputActivationView.setDimensions(height: 50, width: viewWidht)
            self.locationInputActivationView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor,
                                                    paddingTop: 32)
        }
    }

    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }

    func configureLocationInputView() {
        view.addSubview(locationInputView)
        locationInputView.alpha = 0
        locationInputView.delegate = self
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor,
                                 right: view.rightAnchor, height: 200)

        UIView.animate(withDuration: 0.5) {
            self.locationInputActivationView.alpha = 0
            self.locationInputView.alpha = 1
        } completion: { _ in
            
        }
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

//MARK: - LocationInputActivationViewDelegate
extension HomeController: LocationInputActivationViewDelegate {

    func presentLocationInputView() {
        configureLocationInputView()
    }
}


//MARK: - LocationInputViewDelegate
extension HomeController: LocationInputViewDelegate {
    func dismissLocationInputView() {
        UIView.animateKeyframes(withDuration: 0.9, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                    self.locationInputView.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.5) {
                    self.locationInputActivationView.alpha = 1
            }
        }
    }
}
