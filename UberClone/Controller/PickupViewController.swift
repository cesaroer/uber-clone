//
//  PickupViewController.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 08/05/23.
//

import UIKit
import MapKit

class PickupViewController: UIViewController {

    //MARK: - Properties
    private let mapview = MKMapView()
    var trip: Trip
    
    private var cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "baseline_clear_white_36pt_2x")
        btn.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleDissmisal), for: .touchUpInside)
        return btn
    }()

    private let pickupLabel: UILabel = {
       let label = UILabel()
        label.text = "Do you want to accept the trip?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()

    private var acceptTripBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("GO", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(acceptTrip), for: .touchUpInside)
        return btn
    }()

    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapview()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK: - helpers
    func configureUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                            left: view.leftAnchor, paddingLeft: 16)

        view.addSubview(mapview)
        mapview.setDimensions(height: 270, width: 270)
        mapview.layer.cornerRadius = 270 / 2
        mapview.centerY(inView: self.view, constant: -200)
        mapview.centerX(inView: self.view)

        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: self.view)
        pickupLabel.anchor(top: mapview.bottomAnchor, paddingTop: 16)

        view.addSubview(acceptTripBtn)
        acceptTripBtn.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
    }
    
    func configureMapview() {
        let region = MKCoordinateRegion(center: trip.pickupCoords,
                                        latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        mapview.setRegion(region, animated: true)
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoords
        mapview.addAnnotation(anno)
        mapview.selectAnnotation(anno, animated: true)
    }


    //MARK: - Selector
    @objc func handleDissmisal() {
        dismiss(animated: true)
    }
    
    @objc func acceptTrip() {
        launchRouteOnMaps(from: trip.pickupCoords, to: trip.destinationCoords)
    }

    //MARK: - API
}
