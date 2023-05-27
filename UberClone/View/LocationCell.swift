//
//  LocationCellTableViewCell.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 21/04/23.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {
//MARK: - Properties
    static let reuseIdentifier = "LocationCellTableViewCell"

    var placeMark: MKPlacemark? {
        didSet {
            titleLabel.text = placeMark?.name
            addressLabel.text = placeMark?.address
        }
    }
    
     public let titleLabel: UILabel = {
       let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    public let addressLabel: UILabel = {
       let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

//MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Helpers

}
