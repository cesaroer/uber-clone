//
//  MenuHeader.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 22/05/23.
//

import UIKit

class MenuHeader: UIView {
    // MARK: - Properties
    
    
    var user: User? {
        didSet {
            fullnameLabel.text = user?.fullname
            emailLabel.text = user?.email
        }
    }
    
    private let profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let fullnameLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.text = "John Do"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let emailLabel: UILabel = {
       let label = UILabel()
        label.textColor = .lightGray
        label.text = "cesaemeial@com.com"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    // MARK: - LifeCycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .backgroundColor
        
        addSubview(profileImageView)
        profileImageView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor,
                                paddingTop: 4, paddingLeft: 12, width: 64 ,height: 64)
        
        profileImageView.layer.cornerRadius = 64 / 2
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4

        addSubview(stack)
        stack.centerY(inView: profileImageView,
                      leftAnchor: profileImageView.rightAnchor, paddingLeft: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - helpers
    // MARK: - selectors
}
