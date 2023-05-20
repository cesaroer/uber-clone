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

enum AnnotationType: String {
    case pickup
    case destination
}

class HomeController: UIViewController {
    
    //MARK: - Properties
    private let mapView = MKMapView()
    private var route: MKRoute?
    private let locationManager = LocationHandler.shared.locationManager
    static let NotificationDone = NSNotification.Name(rawValue: "Done")

    private let locationInputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let rideActionView = RideActionView()

    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private var user: User? {
        didSet {
            locationInputView.user = user
            if user?.accountType == .passgenger {
                fetchDrivers()
                configureLocationInputActivationView()
                observeCurrentTrip()
            }else {
                observeTrips()
            }
        }
    }

    private var trip: Trip? {
        didSet {
            guard let user = user else { return }
            if user.accountType == .driver {
                guard let trip = trip, trip.state == .requested else { return }
                let vc = PickupViewController(trip: trip)
                vc.modalPresentationStyle = .custom
                vc.delegate = self
                self.present(vc, animated: true)
            } else {
                
            }
        }
    }
    
    private final let locationInputViewHeight: CGFloat  = 200
    private final let rideActionViewHeight: CGFloat  = 300
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

    override func viewWillAppear(_ animated: Bool) {
        guard let trip = trip else { return }
        
        
    }

    //MARK: - Shared API
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
    
    //MARK: - PASSENGER API

    /// Observe for user
    func observeCurrentTrip() {
        PassengerService.shared.observeCurrentTrip { trip in
            self.trip = trip
            guard let state = trip.state,
                  let driverUUID = trip.driverUUID else { return }
            
            switch state {
            case .requested:
                break
            case .accepted:
                self.shouldPresentLoadingView(false)
                self.removeAnnotationsAndOverlays()
                self.zoomForActiveTrip(with: driverUUID)
                Service.shared.fetchUserData(uid: driverUUID) { driver in
                    self.animateRideActionView(shouldShow: true ,
                                               config: .tripAccepted, user: driver)
                }
            case .driverArrived:
                self.rideActionView.config = .driverArrived
            case .inProgress:
                self.rideActionView.config = .tripInProgress
            case .arrivedAtDestination:
                self.rideActionView.config = .endTrip
            case .completed:
                PassengerService.shared.deleteTrip { erro, ref in
                    self.animateRideActionView(shouldShow: false)
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    self.presentAlertController(title: "Trip Compleated",
                                                withMessage: "Rate the driver later")
                    self.locationInputActivationView.alpha = 1
                }
            }
        }
    }
    
    func fetchDrivers() {
        guard let location  = locationManager?.location,
              user?.accountType == .passgenger else { return }
        PassengerService.shared.fetchDrivers(location: location) { driver in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(coordinate: coordinate, uid: driver.uid)
            
            var driverIsVisible: Bool {
                
                return self.mapView.annotations.contains { annotation in
                    guard let driverAnnotation = annotation as? DriverAnnotation
                          else { return false }
                    if driverAnnotation.uid == driver.uid {
                        driverAnnotation.updateAnnotationPosition(withCoordinate: coordinate)
                        self.zoomForActiveTrip(with: driverAnnotation.uid)
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

    //MARK: - Drivers API

    ///Observe for Drivers
    func observeTrips() {
        DriverService.shared.observetrips { trip in
            self.trip = trip
        }
    }

    func observeIfTripCancelled(trip: Trip) {
        DriverService.shared.observeTripCancelled(trip: trip) {
            self.removeAnnotationsAndOverlays()
            self.animateRideActionView(shouldShow: false)
            self.centerMapOnUserLocation()
            self.presentAlertController(title: "Ups!",
                                        withMessage: "The passenger has cancelled this trip")
        }
    }

    func startTrip() {
        guard let trip = self.trip else { return }
        DriverService.shared.updateTripState(trip: trip, state: .inProgress) { error, ref in
            self.rideActionView.config = .tripInProgress
            self.removeAnnotationsAndOverlays()
            self.mapView.addAnnotationAndSelect(forCoordinates: trip.destinationCoords)

            let placeMark = MKPlacemark(coordinate: trip.destinationCoords)
            let mapItem = MKMapItem(placemark: placeMark)
            self.setCustomRegion(with: .destination, withCorrdinates: trip.destinationCoords)
            self.generatePolyline(toDestination: mapItem, setVisibleMapArea: true)
            self.mapView.zoomToFir(annotations: self.mapView.annotations)
        }
    }
    
    //MARK: - Helpers
    func configure() {
        configureUI()
        fetchUserData()
    }
    func configureUI() {
        configureMapView()
        configureRideActionView()
        
        view.addSubview(actionButton)
        actionButton.alpha = 0
        actionButton.frame = CGRect(x: 0, y: 63, width: 45, height: 45)

        UIView.animate(withDuration: 1.5, delay: 0.3) {
            self.actionButton.alpha = 1
            self.actionButton.frame.origin.x = 16

        } completion: { _ in
            let topAnc = self.view.safeAreaLayoutGuide.topAnchor
            self.actionButton.anchor(top: topAnc, left: self.view.leftAnchor, paddingTop: 4,
                                     paddingLeft: 16, width: 45, height: 45)
        }
        self.configureTableView()
    }

    func configureLocationInputActivationView() {
        let viewWidht = self.view.frame.width - 64
        let firstX = (self.view.frame.width / 2) - (viewWidht / 2)
        
        view.addSubview(locationInputActivationView)
        locationInputActivationView.delegate = self
        locationInputActivationView.alpha = 0
        locationInputActivationView.frame = CGRect(x: firstX, y: 110,
                                                   width: viewWidht, height: 50)
        UIView.animate(withDuration: 1.5) {
            self.locationInputActivationView.alpha = 1
            self.locationInputActivationView.frame.origin.y = 125
            
        } completion: { _ in
            let topAnc = self.view.safeAreaLayoutGuide.topAnchor
            self.locationInputActivationView.centerX(inView: self.view)
            self.locationInputActivationView.setDimensions(height: 50, width: viewWidht)
            self.locationInputActivationView.anchor(top: topAnc, paddingTop: 66)
            
        }
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
            self.locationInputView.startTyping()
        }
    }

    func configureRideActionView() {
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        rideActionView.frame = CGRect(x: 0, y: view.frame.height,
                                      width: view.frame.width, height: rideActionViewHeight)
        
        let blurView = UIVisualEffectView()
        blurView.frame = CGRect(x: 0, y: 0,
                                width: view.frame.width, height: rideActionViewHeight)
        blurView.effect = UIBlurEffect(style: .systemThinMaterialDark)
        blurView.alpha = 0.98
        rideActionView.insertSubview(blurView, at: 0)
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

    func animateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil,
                               config: RideActionViewconfig? = nil,
                               user: User? = nil) {
        let yOrigin = shouldShow ? self.rideActionViewHeight : 0
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = self.view.frame.height - yOrigin
        }

        if shouldShow {
            if let destinati = destination {
                self.rideActionView.destination = destinati
            }

            if let user = user {
                self.rideActionView.user = user
            }

            if let config = config {
                self.rideActionView.config = config
            }
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
                self.animateRideActionView(shouldShow: false)

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

    func generatePolyline(toDestination destination: MKMapItem,
                          setVisibleMapArea: Bool = false) {
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
            
            if setVisibleMapArea {
                self.mapView.setVisibleMapArea(polyline: polyline)
            }
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

    func centerMapOnUserLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 2000, longitudinalMeters: 2000)
        self.mapView.setRegion(region, animated: true)
    }

    func setCustomRegion(with type: AnnotationType, withCorrdinates coordinates: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinates, radius: 100, identifier: type.rawValue)
        locationManager?.monitoredRegions.forEach({ oldRegion in
            locationManager?.stopMonitoring(for: oldRegion)
        })
        locationManager?.startMonitoring(for: region)
    }

    func zoomForActiveTrip(with driverUUID: String ) {
        var annotations = [MKAnnotation]()
        self.mapView.annotations.forEach { annotation in
            if let driverAnnotation = annotation as? DriverAnnotation,
                driverAnnotation.uid == driverUUID {
                annotations.append(driverAnnotation)
            }

            if let userAnnotation = annotation as? MKUserLocation {
                annotations.append(userAnnotation)
            }
        }
        self.mapView.zoomToFir(annotations: annotations)
    }

}


//MARK: - MKMapViewDelegate
extension HomeController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = self.user,
              user.accountType == .driver,
              let location = userLocation.location else { return }
        DriverService.shared.updateDriverLocation(location: location)
    }
    
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

//MARK: - CLLocationManagerDelegate
extension HomeController: CLLocationManagerDelegate {
    func enableLocationServices() {
        locationManager?.delegate = self
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

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: didStartMonitoringFor pickup \(region)")
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: didStartMonitoringFor destination \(region)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let trip =  self.trip else { return }
        
        if region.identifier == AnnotationType.pickup.rawValue {
            self.trip?.state = .driverArrived
            DriverService.shared.updateTripState(trip: trip, state: .driverArrived) { error, ref in
                self.rideActionView.config = .pickupPassenger
            }
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: didStartMonitoringFor destination \(region)")
            
            self.trip?.state = .arrivedAtDestination
            DriverService.shared.updateTripState(trip: trip, state: .arrivedAtDestination) { error, ref in
                self.rideActionView.config = .endTrip
            }
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
        let destinationCoordinates = searchResults[indexPath.row].coordinate
        let mark = MKPlacemark(coordinate: destinationCoordinates)// to get accuracy

        configureActionButton(config: .dismissActionView)
        generatePolyline(toDestination: MKMapItem(placemark: mark), setVisibleMapArea: true)

        dismissLocationView(showSearchBar: false) { _ in
            self.locationInputView.removeFromSuperview()
            //FIXME: - here just and fixme mark example
            self.mapView.addAnnotationAndSelect(forCoordinates: destinationCoordinates)
            self.animateRideActionView(shouldShow: true,
                                       destination: self.searchResults[indexPath.row],
                                       config: .requestRide)
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
            DispatchQueue.main.async {
                self.searchResults = placeMarks
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - RideActionviewDelegate
extension HomeController: RideActionviewDelegate {

    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate,
              let destinationCoordinates = view.destination?.coordinate else { return }
        
        self.shouldPresentLoadingView(true, message: "Finding you a ride!")
        PassengerService.shared.uploadTrip(pickupCoordinates: pickupCoordinates,
                                           destinationCoordinates: destinationCoordinates) { error, dbRef in
            if let error = error {
                print("DEBUG error \(error.localizedDescription)")
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, options: []) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            } completion: { _ in
                
            }
        }
    }

    func cancelTrip() {
        PassengerService.shared.deleteTrip { error, ref in
            if let error = error {
                print("DEBUG error deliting trip \(error.localizedDescription)")
                return
            }

            self.animateRideActionView(shouldShow: false)
            self.removeAnnotationsAndOverlays()
//            let image = #imageLiteral(resourceName: "baseline_menu_black_36dp")
//            self.actionButton.setImage(image, for: .normal)
//            self.actionButtonState = .showMenu
            self.configureActionButton(config: .showMenu)
            self.centerMapOnUserLocation()
            self.locationInputActivationView.alpha = 1
        }
    }
    
    func pickupPassenger() {
        startTrip()
    }

    func dropOffPassenger() {
        guard let trip = self.trip else { return }
        self.trip?.state = .completed
        DriverService.shared.updateTripState(trip: trip, state: .completed) { erro, ref in
            if let error = erro {
                print("DEBUG error completing trip \(error.localizedDescription)")
                return
            }

            self.removeAnnotationsAndOverlays()
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)

        }
    }
}

// MARK: - PickupControllerDelegate
extension HomeController: PickupControllerDelegate {
    func didAcceptTrip(_ trip: Trip, controller: UIViewController) {
        self.trip = trip
        self.mapView.addAnnotationAndSelect(forCoordinates: trip.pickupCoords)
        self.setCustomRegion(with: .pickup, withCorrdinates: trip.pickupCoords)
        
        let placeMark = MKPlacemark(coordinate: trip.pickupCoords)
        let mapItem = MKMapItem(placemark: placeMark)
        
        self.trip?.state = .accepted
        generatePolyline(toDestination: mapItem, setVisibleMapArea: true)
        observeIfTripCancelled(trip: trip)

        controller.dismiss(animated: true) {
            guard let passengerUUID = trip.passengerUUID else { return }
            Service.shared.fetchUserData(uid: passengerUUID) { user in
                self.animateRideActionView(shouldShow: true, destination: placeMark,
                                           config: .tripAccepted, user: user)
            }
            //launchRouteOnMaps(from: self.trip.pickupCoords, to: self.trip.destinationCoords)
        }
    }
}
