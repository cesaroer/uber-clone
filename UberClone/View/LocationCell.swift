//
//  LocationCellTableViewCell.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 21/04/23.
//

import UIKit

class LocationCell: UITableViewCell {
//MARK: - Properties
    static let reuseIdentifier = "LocationCellTableViewCell"
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.textColor = .darkGray
        label.text = "1234 Main Street"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let addressLabel: UILabel = {
       let label = UILabel()
        label.textColor = .lightGray
        label.text = "1234 Washinton"
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