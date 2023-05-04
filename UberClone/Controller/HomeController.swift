//
//  HomeController.swift
//  UberClone
//
//  Created by Cesar Vargas on 24/09/21.
//

import UIKit
import Firebase
import MapKit

enum ActionButtonStates {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

class HomeController: UIViewController {
    
    //MARK: - Properties
    private let mapView = MKMapView()
    private var route: MKRoute?
    private let locationManager = LocationHandler.shared.locationManager
    static let NotificationDone = NSNotification.Name(rawValue: "Done")

    private let locationInputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()

    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private var user: User? {
        didSet {
            locationInputView.user = user
        }
    }
    
    private final let locationInputViewHeight: CGFloat  = 200
    private var actionButtonState = ActionButtonStates()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "baseline_menu_black_36dp")
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .white
        button.tintColor = .black
        button.layer.cornerRadius = 0.5 * 45
        button.clipsToBounds = true
        button.addShadow()
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        

        checkIfUserIsLoggedIn()
        enableLocationServices()
        //signOut()
    }
    
    //MARK: - API
    func checkIfUserIsLoggedIn() {
        if( Auth.auth().currentUser?.uid == nil) {
            DispatchQueue.main.async {
                NotificationCenter.default
                    .post(name: HomeController.NotificationDone, object: nil)
            }
        }else {
            configure()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                NotificationCenter.default
                    .post(name: HomeController.NotificationDone, object: nil)
            }
        }catch let error {
            print("DEBUG: Error \(error.localizedDescription)")
        }
    }
    
    func fetchUserData() {
        Service.shared.fetchUserData { user in
            self.user = user
        }
    }
    
    func fetchDrivers() {

        guard let location  = locationManager?.location else { return }
        Service.shared.fetchDrivers(location: location) { driver in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(coordinate: coordinate, uid: driver.uid)
            
            var driverIsVisible: Bool {
                
                return self.mapView.annotations.contains { annotation in
                    guard let driverAnnotation = annotation as? DriverAnnotation
                          else { return false }
                    if driverAnnotation.uid == driver.uid {
                        driverAnnotation.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    return false
                }
            }
            
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    //MARK: - Helpers
    func configure() {
        configureUI()
        fetchUserData()
        fetchDrivers()
    }
    func configureUI() {
        configureMapView()
        
        view.addSubview(actionButton)
        actionButton.alpha = 0
        actionButton.frame = CGRect(x: 0, y: 63, width: 45, height: 45)

        view.addSubview(locationInputActivationView)
        let viewWidht = self.view.frame.width - 64
        let firstX = (self.view.frame.width / 2) - (viewWidht / 2)
        
        locationInputActivationView.delegate = self
        locationInputActivationView.alpha = 0
        locationInputActivationView.frame = CGRect(x: firstX, y: 110,
                                                   width: viewWidht, height: 50)

        UIView.animate(withDuration: 1.5) {
            self.actionButton.alpha = 1
            self.actionButton.frame.origin.x = 16
            
            self.locationInputActivationView.alpha = 1
            self.locationInputActivationView.frame.origin.y = 125
        } completion: { _ in
            let topAnc = self.view.safeAreaLayoutGuide.topAnchor
            self.actionButton.anchor(top: topAnc, left: self.view.leftAnchor, paddingTop: 4,
                                     paddingLeft: 16, width: 45, height: 45)
    
            self.locationInputActivationView.centerX(inView: self.view)
            self.locationInputActivationView.setDimensions(height: 50, width: viewWidht)
            self.locationInputActivationView.anchor(top: topAnc, paddingTop: 66)
        }
        self.configureTableView()
    }

    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
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
            self.actionButton.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
                self.tableView.alpha = 1
            } completion: { _ in
                
            }
        } completion: { _ in

        }
    }

    func dismissLocationView(showSearchBar: Bool, completionBlock: ((Bool) -> Void)? = nil) {
        let animationOptions: UIView.AnimationOptions = .curveEaseOut
        let keyframeAnimationOptions = UIView.KeyframeAnimationOptions(rawValue: animationOptions.rawValue)
        
        UIView.animateKeyframes(withDuration: 0.9, delay: 0,
                                options: keyframeAnimationOptions,
                                animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.locationInputView.alpha = 0
                self.actionButton.alpha = 1
                self.tableView.frame.origin.y = self.view.frame.height - 50
                self.tableView.alpha = 0
            }
    
            if showSearchBar {
                UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.5) {
                    self.locationInputActivationView.alpha = 1
                }
            }
        }, completion: completionBlock)
    }

    fileprivate func configureActionButton(config: ActionButtonStates) {
        switch config {
        case .showMenu:
            let image = #imageLiteral(resourceName: "baseline_menu_black_36dp")
            self.actionButton.setImage(image, for: .normal)
            self.actionButtonState = .showMenu
        case .dismissActionView:
            let image = #imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1")
            self.actionButton.setImage(image, for: .normal)
            self.actionButtonState = .dismissActionView
        }
    }
    
    // MARK: - Selectors
    @objc func actionButtonPressed() {
        switch actionButtonState {
        case .showMenu:
            let image = #imageLiteral(resourceName: "baseline_menu_black_36dp")
            actionButton.setImage(image, for: .normal)
        case .dismissActionView:
            removeAnnotationsAndOverlays()
            mapView.showAnnotations(mapView.annotations, animated: true)

            UIView.animate(withDuration: 0.3) {
                self.locationInputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
            }
        }
    }
}

//MARK: - MKMapView helper functions
extension HomeController {
    func searchBy(naturalLanguajeQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguajeQuery
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            
            response.mapItems.forEach { mapItem in
                results.append(mapItem.placemark)
            }
            
            completion(results)
        }
    }

    func generatePolyline(toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .any

        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { response, error in
            guard let response = response else  { return }
            self.route = response.routes[0]

            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }

    func removeAnnotationsAndOverlays() {
        mapView.annotations.forEach { annotation in
            if let ann = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(ann)
            }
        }
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
}


//MARK: - MKMapViewDelegate
extension HomeController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: DriverAnnotation.description())
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        
        return nil
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = UIColor.black
            lineRenderer.lineWidth = 4
            return lineRenderer
        }

        return MKOverlayRenderer()
    }
}

//MARK: - LocationServices
extension HomeController {
    
    func enableLocationServices() {
        
        switch locationManager?.authorizationStatus {
        case .notDetermined:
            print("DEBUG: notDetermined")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted,.denied:
            break
        case .authorizedAlways:
            print("DEBUG: authorizedAlways")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: authorizedWhenInUse")
            locationManager?.requestAlwaysAuthorization()
        case .none:
            print("DEBUG: none")
        @unknown default:
            break
        }
    }
    

}

//MARK: - TableView
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier,
                                                 for: indexPath) as! LocationCell
        
        if indexPath.section == 1 {
            cell.placeMark = searchResults[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResults.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlaceMArk = searchResults[indexPath.row]
        
        configureActionButton(config: .dismissActionView)
        //let destination = MKMapItem(placemark: selectedPlaceMArk)
        //generatePolyline(toDestination: destination)
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark:
                                            MKPlacemark(coordinate: selectedPlaceMArk.coordinate))
        request.transportType = .automobile
        //request.requestsAlternateRoutes = true

        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { response, error in
            guard let response = response else  { return }
            self.route = response.routes[0]

            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }

        dismissLocationView(showSearchBar: false) { _ in
            self.locationInputView.removeFromSuperview()
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlaceMArk.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
//            let annotations = self.mapView.annotations.filter { $0.isKind(of: DriverAnnotation.self)}
            
            var annotations = [MKAnnotation]()
            self.mapView.annotations.forEach { annotation in
                if let anno = annotation as? MKUserLocation {
                    annotations.append(anno)
                }

                if let anno = annotation as? MKPointAnnotation {
                    annotations.append(anno)
                }
                
            }
    
            if let polyline = self.route?.polyline {
                self.setVisibleMapArea(polyline: polyline,
                                  edgeInsets: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0))
            }
 

            //self.mapView.showAnnotations(annotations, animated: true)
        }
    }
    
    func setVisibleMapArea(polyline: MKPolyline, edgeInsets: UIEdgeInsets, animated: Bool = true) {
        DispatchQueue.main.async {
            self.mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: edgeInsets, animated: animated)
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
        dismissLocationView(showSearchBar: true) { _ in
            self.locationInputView.removeFromSuperview()
        }
    }
    

    func executeSearch(query: String) {
        searchBy(naturalLanguajeQuery: query) { placeMarks in
            self.searchResults = placeMarks
            self.tableView.reloadData()
        }
    }
}


