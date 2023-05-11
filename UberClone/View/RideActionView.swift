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

    var config = RideActionViewconfig()
    var buttonAction = ButtonAction()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "Coffe"
        label.textAlignment = .center
        return label
    }()
    
    private let addressLabel: UILabel = {
       let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Coffe Street Whasington"
        label.textAlignment = .center
        return label
    }()

    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        
        view.addSubview(label)
        label.centerX(inView: view)
        label.centerY(inView: view)
        return view
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
        
        backgroundColor = .white
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
        separatorView.backgroundColor = .gray
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
        delegate?.uploadTrip(self)
    }

    //MARK: - Helpers
    func configureUI(withConfig: RideActionViewconfig) {
        
    }
    
}
