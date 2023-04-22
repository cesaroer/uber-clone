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
    private let tableView = UITableView()
    private var fullname: String = "" {
        didSet {
            locationInputView.titleLabel.text = fullname
        }
    }
    
    private final let locationInputViewHeight: CGFloat  = 200
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
        //signOut()
        enableLocationServices()
        fetchUserData()
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
    
    func fetchUserData() {
        Service.shared.fetchUserData { fullname in
            self.fullname = fullname
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
        self.configureTableView()
    }

    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.alpha = 0
        tableView.rowHeight = 60
        tableView.register(LocationCell.self,
                           forCellReuseIdentifier: LocationCell.reuseIdentifier)
        let height = (view.frame.height - locationInputViewHeight)
        tableView.frame = CGRect(x: 0, y: view.frame.height - 50,
                                 width: view.frame.width, height: height)
        
        view.addSubview(tableView)
        tableView.tableFooterView = UIView()
    }

    func configureLocationInputView() {
        view.addSubview(locationInputView)
        locationInputView.alpha = 0
        locationInputView.delegate = self
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor,
                                 right: view.rightAnchor, height: 200)

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            self.locationInputActivationView.alpha = 0
            self.locationInputView.alpha = 1
            UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
                self.tableView.alpha = 1
            } completion: { _ in
                
            }
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

//MARK: - TableView
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier,
                                                 for: indexPath) as! LocationCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
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
        let animationOptions: UIView.AnimationOptions = .curveEaseOut
        let keyframeAnimationOptions = UIView.KeyframeAnimationOptions(rawValue: animationOptions.rawValue)

        UIView.animateKeyframes(withDuration: 0.9, delay: 0,
                                options: keyframeAnimationOptions) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.locationInputView.alpha = 0
                self.tableView.frame.origin.y = self.view.frame.height - 50
                self.tableView.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.5) {
                self.locationInputActivationView.alpha = 1
            }
        } completion: { _ in
            self.locationInputView.removeFromSuperview()
        }
    }
}


