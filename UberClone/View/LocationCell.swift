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

//MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Helpers

}
