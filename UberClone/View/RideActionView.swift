//
//  RideActionView.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 05/05/23.
//

import UIKit
import MapKit

enum RideActionViewconfig {
    case requestRide
    case tripAccepted
    case driverArrived
    case pickupPassenger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction {
    case requestRide
    case cancel
    case getdirections
    case pickup
    case dropOff

    var description: String {
        switch self {
        case .requestRide:
            return "Confirm UberX"
        case .cancel:
            return "Cancel Ride"
        case .getdirections:
            return "Get Directions"
        case .pickup:
            return "Pickup Passenger"
        case .dropOff:
            return "Drop Off Passenger"
        }
    }

    init() {
        self = .requestRide
    }
}


protocol RideActionviewDelegate: AnyObject {
    func uploadTrip(_ view: RideActionView)
    func cancelTrip()
}

class RideActionView: UIView {

    //MARK: - Properties
    weak var delegate: RideActionviewDelegate?
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }

    var config = RideActionViewconfig() {
        didSet {
            configureUI(with: self.config)
        }
    }
    var buttonAction = ButtonAction()
    var user: User?
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let addressLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()

    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(inView: view)
        infoViewLabel.centerY(inView: view)
        return view
    }()

    private let infoViewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        return label
    }()

    private let infoLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "UberX"
        label.textAlignment = .center
        return label
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle("Confirm UberX", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - LifeCicle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white.withAlphaComponent(0.2)
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self )
        stack.anchor(top: topAnchor, paddingTop: 12)

        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 16, width: 60, height: 60)
        infoView.layer.cornerRadius = 30

        addSubview(infoLabel)
        infoLabel.centerX(inView: self)
        infoLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)

        let separatorView = UIView()
        separatorView.backgroundColor = .white.withAlphaComponent(0.85)
        addSubview(separatorView)
        separatorView.anchor(top: infoLabel.bottomAnchor, left: leftAnchor,
                             right: rightAnchor, paddingTop: 8, height: 0.75)

        addSubview(actionButton)
        actionButton.anchor(left: leftAnchor,bottom: safeAreaLayoutGuide.bottomAnchor,
                            right: rightAnchor, paddingLeft: 20, paddingBottom: 12,
                            paddingRight: 20, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Selectors
    @objc func actionButtonPressed() {
        switch buttonAction {
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            delegate?.cancelTrip()
        case .getdirections:
            print("DEBUG Hanlde getdirections")
        case .pickup:
            print("DEBUG Hanlde pickup")
        case .dropOff:
            print("DEBUG Hanlde dropOff")
        }
    }

    //MARK: - Helpers
    private func configureUI(with config: RideActionViewconfig) {
        switch self.config {
        case .requestRide:
            buttonAction = .requestRide
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripAccepted:
            guard let user = self.user else { return }
            DispatchQueue.main.async {
                if user.accountType == .passgenger {
                    self.buttonAction = .getdirections
                    self.actionButton.setTitle(self.buttonAction.description, for: .normal)
                    self.titleLabel.text = "On Route To Passenger"
                    self.addressLabel.text = "Pickup"
                } else {
                    self.buttonAction = .cancel
                    self.actionButton.setTitle(self.buttonAction.description, for: .normal)
                    self.titleLabel.text = "Driver On Route"
                    self.addressLabel.text = "Your driver"
                }
                
                self.infoViewLabel.text = String(user.fullname.first ?? "X")
                self.infoLabel.text = user.fullname
            }
        case .driverArrived:
            guard let user = self.user, user.accountType == .driver else { return }
            titleLabel.text = "Driver has arrived"
            addressLabel.text = "Please meet driver at pickup location"
            
        case .pickupPassenger:
            titleLabel.text = "Arrived At Passenger Location"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripInProgress:
            guard let user = self.user else { return }
            titleLabel.text = "On Route Destination"
            if user.accountType == .driver {
                actionButton.setTitle("Trip In Progress", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .getdirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
        case .endTrip:
            guard let user = self.user else { return }
            if user.accountType == .driver {
                actionButton.setTitle("Arrived at Destination", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
        }
        
    }
    
}
